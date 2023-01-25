const std = @import("std");
const common = @import("common.zig");

const ds = @import("psy-ds");

const Pairs = struct {
    one: [2]i64,
    two: [2]i64,
};

pub fn run() void {
    common.mkline("AOC 4: part 1");

    const allocator = std.heap.page_allocator;

    var list = ds.DynArr(Pairs).init(&allocator);
    defer list.destroy();

    const input_file = "src/aoc/2022/input/4.txt";
    const file_contents = common.fileToBuf(input_file, allocator) catch |err| {
        std.log.err("could not open file {s}: {}", .{ input_file, err });
        return;
    };
    defer allocator.free(file_contents);

    // do the annoying parsing
    var it = std.mem.split(u8, file_contents, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;

        var lit = std.mem.split(u8, line, ",");

        // 20-45,13-44
        // 7-8,8-28
        // 3-39,14-97
        // ...

        // for the sake of brevity, I'm doing `catch unreachable' here.  don't
        // do that in more error critical software.

        var one = lit.next().?;
        var two = lit.next().?;

        var sone = std.mem.split(u8, one, "-");
        var stwo = std.mem.split(u8, two, "-");

        const ione_01 = std.fmt.parseInt(i64, sone.next().?, 10) catch unreachable;
        const ione_02 = std.fmt.parseInt(i64, sone.next().?, 10) catch unreachable;

        const itwo_01 = std.fmt.parseInt(i64, stwo.next().?, 10) catch unreachable;
        const itwo_02 = std.fmt.parseInt(i64, stwo.next().?, 10) catch unreachable;

        var p = Pairs{
            .one = [2]i64{ ione_01, ione_02 },
            .two = [2]i64{ itwo_01, itwo_02 },
        };

        list.add(p) catch unreachable;
    }

    var ix: usize = 0;
    var count: usize = 0;
    var overlap: usize = 0;
    while (ix < list.len) : (ix += 1) {
        const r = list.at(ix).*;

        var is_superset = false;

        { // for supersets
            const a = r.one[0] <= r.two[0] and r.one[1] >= r.two[1];
            const b = r.two[0] <= r.one[0] and r.two[1] >= r.one[1];
            is_superset = a or b;

            if (is_superset) {
                count += 1;
            }
        }

        { // for overlaps
            const a =
                (r.one[0] >= r.two[0] and r.one[0] <= r.two[1]) or
                (r.one[1] >= r.two[0] and r.one[1] <= r.two[1]);

            if (a or is_superset) {
                overlap += 1;
            }
        }
    }

    std.log.info("part-1: supersets: {}", .{count});
    std.log.info("part-2: overlaps : {}", .{overlap});
}
