const std = @import("std");

const Allocator = std.mem.Allocator;
const common = @import("common.zig");

const input = @embedFile("input/1.txt");

fn implrun() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("leaks will drown us all");

    // part 1
    const list_type = i32;

    var ls0 = std.ArrayList(list_type).init(alloc);
    defer ls0.deinit();

    var ls1 = std.ArrayList(list_type).init(alloc);
    defer ls1.deinit();

    var doc = try common.tokenize(alloc, input, .{ .include_terminator = false });
    for (doc.tokens.items, 0..) |tok, ix| {
        switch (@mod(ix, 2)) {
            0 => {
                const num1 = try std.fmt.parseInt(list_type, tok.data, 0);
                try ls0.append(num1);
            },
            1 => {
                const num2 = try std.fmt.parseInt(list_type, tok.data, 0);
                try ls1.append(num2);
            },
            else => @panic("and in strange aeons death might die"),
        }
    }
    doc.deinit();

    std.mem.sort(list_type, ls0.items, {}, std.sort.asc(list_type));
    std.mem.sort(list_type, ls1.items, {}, std.sort.asc(list_type));

    var answer: u32 = 0;
    for (ls0.items, ls1.items) |e0, e1| answer += @abs(e0 - e1);

    std.log.debug("1. p1. answer: {}", .{answer});

    // part 2
    var mo = std.AutoHashMap(i32, usize).init(alloc);
    defer mo.deinit();

    for (ls1.items) |e| {
        const next = blk: {
            var ret: usize = 0;
            if (mo.get(e)) |val| ret = val;
            ret += 1;
            break :blk ret;
        };
        try mo.put(e, next);
    }

    var answer2: i64 = 0;
    for (ls0.items) |e0| {
        const mult: i64 = @intCast(if (mo.get(e0)) |v| v else 0);
        answer2 += e0 * mult;
    }

    std.log.debug("1. p2. answer: {}", .{answer2});
}

pub fn run() void {
    implrun() catch |err| {
        std.log.err("could not complete run: {}", .{err});
    };
}
