const std = @import("std");

const Allocator = std.mem.Allocator;

const input = @embedFile("input/3.txt");

const Preprocessor = struct {
    text: []u8,
    alloc: Allocator,
    donts: std.ArrayList(usize),
    dos: std.ArrayList(usize),

    pub fn init(a: Allocator, s: []u8) Preprocessor {
        return .{
            .alloc = a,
            .text = s,
            .donts = std.ArrayList(usize).init(a),
            .dos = std.ArrayList(usize).init(a),
        };
    }

    pub fn deinit(self: *Preprocessor) void {
        self.donts.deinit();
        self.dos.deinit();
    }

    pub fn preprocess(self: *Preprocessor) void {
        var i: usize = 0;
        while (std.mem.indexOf(u8, self.text[i..], "don't()")) |ix| : (i += ix + 1)
            self.donts.append(i + ix) catch @panic("oom");

        i = 0;
        while (std.mem.indexOf(u8, self.text[i..], "do()")) |ix| : (i += ix + 1)
            self.dos.append(i + ix) catch @panic("oom");

        var last: usize = 0;
        for (self.donts.items) |b| {
            const from = b;

            loop: for (self.dos.items[last..], 0..) |doix, ix| {
                if (from < doix) {
                    const to = doix;
                    @memset(self.text[from..to], 'X');
                    last = ix;
                    break :loop;
                }
            }
        }
    }
};

const Program = struct {
    allocator: Allocator,
    opar_ixs: std.ArrayList(usize),

    pub fn init(a: Allocator) Program {
        return .{
            .allocator = a,
            .opar_ixs = std.ArrayList(usize).init(a),
        };
    }

    fn findOparIxs(self: *Program, s: []const u8) void {
        self.opar_ixs.clearRetainingCapacity();
        for (s, 0..) |c, ix| if (c == '(') self.opar_ixs.append(ix) catch @panic("oom");
    }

    /// check to see that ( has mul before it, and only keep those occurences.
    fn oparIxsPrefixedMul(self: *Program, s: []const u8) void {
        var remove = std.ArrayList(usize).init(self.allocator);
        defer remove.deinit();

        for (self.opar_ixs.items) |par_ix| {
            if (par_ix < 3) remove.append(par_ix) catch @panic("oom");

            if (!std.mem.eql(u8, s[(par_ix - 3)..par_ix], "mul"))
                remove.append(par_ix) catch @panic("oom");
        }

        for (remove.items) |rm| {
            for (self.opar_ixs.items, 0..) |it, ix| {
                if (it == rm) _ = self.opar_ixs.orderedRemove(ix);
            }
        }
    }

    /// this assumes that oparIxsPrefixedMul was run before this
    fn parseAtIndex(self: *Program, s: []const u8, ix: usize) i64 {
        _ = self;

        var d: i64 = 0;
        var D: i64 = 0;
        var agg: i64 = 0;
        var cur: usize = 0;

        cur += 1; // skip first (

        while (s[ix + cur] != ')') {
            switch (s[ix + cur]) {
                ',' => {
                    d = agg;
                    agg = 0;
                },
                '0'...'9' => {
                    agg *= 10;
                    agg += (s[ix + cur] - 0x30);
                },
                else => {
                    return 0;
                },
            }

            cur += 1;
        }

        D = agg;
        return d * D;
    }

    pub fn deinit(self: *Program) void {
        self.opar_ixs.deinit();
    }

    pub fn check(self: *Program, s: []const u8) i64 {
        self.findOparIxs(s);
        // std.log.debug("opar ixs: {any}", .{self.opar_ixs.items});

        self.oparIxsPrefixedMul(s);
        // std.log.debug("opar ixs mul: {any}", .{self.opar_ixs.items});

        var result: i64 = 0;
        for (self.opar_ixs.items) |it|
            result += self.parseAtIndex(s, it);
        return result;
    }
};

const testing = std.testing;

fn checkProg(s: []const u8) i64 {
    var prog = Program.init(testing.allocator);
    const ret = prog.check(s);
    defer prog.deinit();
    return ret;
}

test "mul(2,4)" {
    try testing.expectEqual(@as(i64, 8), checkProg("mul(2,4)"));
    try testing.expectEqual(@as(i64, 14), checkProg("mul(2,4) mul(2,3)"));
    try testing.expectEqual(@as(i64, 8), checkProg(" dul( ((  mul( mul(2,4) dul(4,6) bul(5,4)"));
    try testing.expectEqual(@as(i64, 8), checkProg("mul(2,4) dul(4,6) bul(5,4)"));
    try testing.expectEqual(@as(i64, 161), checkProg("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"));
}

pub fn run() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    {
        // The idea here, instead of making a fun tokenizer, would be to think
        // about what is the actual data we're looking for.  Each mul
        // instruction must have a `(' at minimum.  We extract the indices of
        // all these, and then we iterate checks on them.  if the `(' has `mul'
        // prefixed, then the first part is correct.  The number parser then
        // handles the other half of the validation by indirectly failing if it
        // finds things it does not expect.
        var prog = Program.init(alloc);
        const ret = prog.check(input);
        defer prog.deinit();
        std.log.debug("day 3: 1: {}", .{ret});
    }

    {
        // Will approach this with a preprocessor approach, which should just
        // erase or add invalid characters to ignore full regions.
        var copy = std.mem.zeroes(@TypeOf(input.*));
        @memcpy(&copy, input);

        var p = Preprocessor.init(alloc, &copy);
        defer p.deinit();

        p.preprocess();

        // std.log.debug("donts {any}", .{p.donts.items});
        // std.log.debug("donts {s}", .{copy[p.donts.items[0] .. p.donts.items[0] + 9]});
        // for (p.donts.items) |it| std.log.debug("    - {s}", .{copy[it .. it + 6]});
        // std.log.debug("dos   {any}", .{p.dos.items});
        // for (p.dos.items) |it| std.log.debug("    - {s}", .{copy[it .. it + 6]});

        var prog = Program.init(alloc);
        const ret = prog.check(&copy);
        defer prog.deinit();
        std.log.debug("day 3: 2: {}", .{ret});
    }
}
