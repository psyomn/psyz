const std = @import("std");
const common = @import("common.zig");

pub fn run() void {
    const allocator = std.testing.allocator;

    common.mkline("AOC 3: 1");

    const path = "src/aoc/2022/input/3.txt";
    var buf = common.fileToBuf(path, allocator) catch |err| {
        std.log.err("could not open file: {s}: {}", .{ path, err });
        return;
    };
    defer allocator.free(buf);

    var priority: i64 = 0;

    var it = std.mem.split(u8, buf, "\n");
    while (it.next()) |line| {
        if (line.len == 0) continue;

        const sz: usize = 256;
        var arr: [sz]u8 = .{0} ** sz;

        for (line[0 .. line.len / 2]) |c| {
            arr[c] = 1;
        }

        var found: ?u8 = null;
        for (line[line.len / 2 ..]) |c| {
            if (arr[c] != 0) {
                found = c;
                break;
            }
        }

        switch (found.?) {
            'a'...'z' => |c| priority += c - 'a' + 1,
            'A'...'Z' => |c| priority += c - 'A' + 27,
            else => @panic("illegal character"),
        }
    }

    std.log.info("priority: {}", .{priority});
}
