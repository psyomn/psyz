const std = @import("std");

const common = @import("common.zig");

const Allocator = std.mem.Allocator;

const input = @embedFile("input/2.txt");

pub fn run() void {
    implrun() catch |err| {
        std.log.err("could not run: {}", .{err});
    };
}

const Report = struct {
    cols: std.ArrayList(i32),

    pub const Result = struct {
        safe: bool = false,
        offense_ix: usize = 0,
    };

    pub fn init(a: Allocator) Report {
        return .{
            .cols = std.ArrayList(i32).init(a),
        };
    }

    pub fn deinit(self: *Report) void {
        self.cols.deinit();
    }

    pub fn add(self: *Report, a: i32) !void {
        try self.cols.append(a);
    }

    fn check(items: []const i32) Result {
        var a = items[0];
        var incr = (a - items[1] < 0);
        var decr = (a - items[1] > 0);
        var szok = true;

        for (items[1..], 1..) |el, ix| {
            const diff = @abs(a - el);

            const tmp_szok = szok and (diff >= 1 and diff <= 3);
            const tmp_incr = incr and (a - el < 0);
            const tmp_decr = decr and (a - el > 0);

            if (!tmp_szok) {
                return .{
                    .safe = false,
                    .offense_ix = ix,
                };
            }

            if (incr != tmp_incr) {
                return .{ .safe = false, .offense_ix = ix };
            }

            if (decr != tmp_decr) {
                return .{ .safe = false, .offense_ix = ix - 1 };
            }

            szok = tmp_szok;
            incr = tmp_incr;
            decr = tmp_decr;

            a = el;
        }

        return .{
            .safe = ((incr and !decr) or (!incr and decr)) and szok,
            .offense_ix = 0,
        };
    }

    pub fn isSafe(self: Report) Result { // 246
        return Report.check(self.cols.items);
    }

    pub fn bruteSafe(self: Report) Result {
        const sz = self.cols.items.len;

        for (0..sz) |i| {
            var copy = self.cols.clone() catch @panic("out of memory");
            defer copy.deinit();
            _ = copy.orderedRemove(i);

            const rep = Report.check(copy.items);
            if (rep.safe) {
                return rep;
            }
        }

        return .{ .safe = false };
    }

    pub fn isSafeDampen(self: Report) Result {
        const once = self.isSafe();

        // std.log.debug("day2-2: arr: safe:{} {any}, offense_ix: {}", .{ once.safe, self.cols.items, once.offense_ix });

        if (once.safe) return once;

        var take2 = self.cols.clone() catch {
            @panic("could not alloc more memory");
        };
        defer take2.deinit();

        _ = take2.orderedRemove(once.offense_ix);

        const final = Report.check(take2.items);
        // std.log.debug("  day2-2: take2: arr: safe:{} {any}, offense_ix: {}", .{ final.safe, take2.items, final.offense_ix });

        if (!final.safe and final.offense_ix > 0) {
            var take3 = self.cols.clone() catch @panic("could not alloc more memory");
            defer take3.deinit();

            _ = take3.orderedRemove(final.offense_ix - 1);

            const final3 = Report.check(take3.items);
            // std.log.debug("  day2-2: take3: arr: safe:{} {any}, offense_ix: {}", .{ final3.safe, take3.items, final3.offense_ix });

            return final3;
        }

        return .{ .safe = final.safe, .offense_ix = 0 };
    }
};

fn implrun() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("leaks will drown us all");

    var doc = try common.tokenize(alloc, input, .{ .include_terminator = true });
    defer doc.deinit();

    // how many are safe?
    var curr = Report.init(alloc);
    defer curr.deinit();

    var answer1: usize = 0;
    var answer2: usize = 0;
    var answer3: usize = 0;

    for (doc.tokens.items) |it| {
        if (std.mem.eql(u8, it.data, "\n")) {
            answer1 += if (curr.isSafe().safe) 1 else 0;
            answer2 += if (curr.isSafeDampen().safe) 1 else 0;
            answer3 += if (curr.bruteSafe().safe) 1 else 0;
            curr.deinit();
            curr = Report.init(alloc);
        } else {
            const v: i32 = try std.fmt.parseInt(i32, it.data, 0);
            try curr.add(v);
        }
    }

    std.log.debug("  answer 1: {d}", .{answer1});
    std.log.debug("  answer 2: {d}", .{answer2});
    std.log.debug("  answer 3: {d}", .{answer3});
    std.log.debug("   sample: {any}", .{Report.check(&[_]i32{ 1, 3, 2, 4, 5 })});
    std.log.debug("   sample: {any}", .{Report.check(&[_]i32{ 8, 6, 4, 4, 1 })});
    std.log.debug("   sample: {any}", .{Report.check(&[_]i32{ 1, 3, 6, 7, 9 })});
    std.log.debug("   sample: {any}", .{Report.check(&[_]i32{ 10, 1, 2, 3, 4 })});
}
