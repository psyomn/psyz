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

    pub fn isSafe(self: Report) bool {
        var a = self.cols.items[0];
        var incr = true;
        var decr = true;
        var szok = true;

        for (self.cols.items[1..]) |el| {
            const diff = @abs(a - el);

            szok = szok and (diff >= 1 and diff <= 3);
            incr = incr and (a - el < 0);
            decr = decr and (a - el > 0);

            a = el;
        }

        // std.log.debug("{any}, incr:{} decr:{} szok:{}", .{ self.cols.items, incr, decr, szok });

        return ((incr and !decr) or (!incr and decr)) and szok;
    }

    pub fn isSafeDampen(self: Report) bool {
        var a = self.cols.items[0];
        var incr = true;
        var decr = true;
        var szok = true;

        for (self.cols.items[1..]) |el| {
            const diff = @abs(a - el);

            szok = szok and (diff >= 1 and diff <= 3);
            incr = incr and (a - el < 0);
            decr = decr and (a - el > 0);

            a = el;
        }

        // std.log.debug("{any}, incr:{} decr:{} szok:{}", .{ self.cols.items, incr, decr, szok });

        return ((incr and !decr) or (!incr and decr)) and szok;
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

    for (doc.tokens.items) |it| {
        if (std.mem.eql(u8, it.data, "\n")) {
            answer1 += if (curr.isSafe()) 1 else 0;
            curr.deinit();
            curr = Report.init(alloc);
        } else {
            std.log.debug("conv: {s}", .{it.data});
            const v: i32 = try std.fmt.parseInt(i32, it.data, 0);
            try curr.add(v);
        }
    }

    std.log.debug("  answer 1: {d}", .{answer1});
}
