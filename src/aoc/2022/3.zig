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

    {
        // part 1
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

        std.log.info("part-1: priority: {}", .{priority});
    }

    {
        // part 2
        var priority: i64 = 0;

        var it = std.mem.split(u8, buf, "\n");

        while (true) {
            var l1 = it.next();
            var l2 = it.next();
            var l3 = it.next();

            if (l1) |_| {} else {
                break;
            }
            if (l2) |_| {} else {
                break;
            }
            if (l3) |_| {} else {
                break;
            }

            const ll1 = l1.?;
            const ll2 = l2.?;
            const ll3 = l3.?;
            if (ll1.len == 0) break;

            const sz: usize = 256;
            var arr: [sz]u8 = .{0} ** sz;

            for (ll1) |c| {
                arr[c] = 1;
            }

            for (ll2) |c| {
                if (arr[c] == 1) {
                    arr[c] = 2;
                }
            }

            var found: ?u8 = null;
            for (ll3) |c| {
                if (arr[c] == 2) {
                    arr[c] = 3;
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

        std.log.info("part-2: priority: {}", .{priority});
    }
}
