const std = @import("std");
const fs = std.fs;

const allocator = std.heap.page_allocator;

const common = @import("common.zig");

pub fn run() void {
    run1();
    run2();
}

fn cmpfn(context: void, a: i64, b: i64) bool {
    _ = context;
    return a > b;
}

fn run2() void {
    common.mkline("AOC 1: 2");

    const input_file = "src/aoc/2022/input/1.txt";

    const file_contents = common.fileToBuf(input_file, allocator) catch |err| {
        std.log.err("problem opening file {s}: {}", .{ input_file, err });
        return;
    };
    defer allocator.free(file_contents);

    var it = std.mem.split(u8, file_contents, "\n");
    var buf: [4]i64 = .{0} ** 4;

    var max: i64 = 0;
    var acc: i64 = 0;

    while (it.next()) |tok| {
        if (tok.len > 0) {
            const tmp = std.fmt.parseInt(i64, tok, 10) catch |err| {
                std.log.err("could not parse int str: {s}: {}", .{ tok, err });
                return;
            };

            acc += tmp;
        } else {
            max = if (max > acc) max else acc;
            buf[3] = acc;
            acc = 0;

            std.sort.sort(i64, buf[0..], {}, cmpfn);
        }
    }

    for (buf) |item| {
        std.debug.print("- {d}\n", .{item});
    }

    std.debug.print("result: {d}\n", .{buf[0] + buf[1] + buf[2]});
}

fn run1() void {
    common.mkline("AOC 1: 1");

    const input_file = "src/aoc/2022/input/1.txt";

    const file_contents = common.fileToBuf(input_file, allocator) catch |err| {
        std.log.err("problem opening file {s}: {}", .{ input_file, err });
        return;
    };
    defer allocator.free(file_contents);

    var it = std.mem.split(u8, file_contents, "\n");

    var max: i64 = 0;
    var acc: i64 = 0;

    while (it.next()) |tok| {
        if (tok.len > 0) {
            const tmp = std.fmt.parseInt(i64, tok, 10) catch |err| {
                std.log.err("could not parse int str: {s}: {}", .{ tok, err });
                return;
            };

            acc += tmp;
        } else {
            max = if (max > acc) max else acc;
            acc = 0;
        }
    }

    std.debug.print("max calories: {d}\n", .{max});
}
