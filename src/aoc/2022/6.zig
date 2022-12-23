const std = @import("std");

const common = @import("common.zig");
const ds = @import("psy-ds");

fn ringElsUniq(ring: *ds.Ring(u8)) bool {
    const data = ring.data.?;

    for (data) |el| {
        const needle: [1]u8 = .{el};
        if (std.mem.count(u8, data, needle[0..]) > 1) {
            return false;
        }
    }

    return true;
}

pub fn run() void {
    common.mkline("AOC 6: 1");

    const allocator = std.heap.page_allocator;

    const path = "src/aoc/2022/input/6.txt";
    var buf = common.fileToBuf(path, allocator) catch |err| {
        std.log.err("could not open file: {s}: {}", .{ path, err });
        return;
    };
    defer allocator.free(buf);

    // inline for the lulz
    inline for ([_]usize{ 4, 14 }) |max_letters| {
        var ring = ds.Ring(u8).init(allocator, max_letters);
        defer ring.destroy();

        var result: usize = 0;

        for (buf) |c, i| {
            result = i;
            ring.insert(c) catch unreachable;

            const unique = ringElsUniq(&ring);
            if (unique and i > 3) {
                break;
            }
        }

        std.log.info("index: {}", .{result + 1});
    }
}
