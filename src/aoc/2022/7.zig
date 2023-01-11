const std = @import("std");
const common = @import("common.zig");

const ParseState = enum {
    CDCommand,
    LSCommand,
};

fn parseLS() void {}
fn parseCD() void {}

pub fn run() void {
    common.mkline("AOC 7: 1");

    const allocator = std.heap.page_allocator;
    const input_file = "src/aoc/2022/input/7.txt";
    const file_contents = common.fileToBuf(input_file, allocator) catch |err| {
        std.log.err("problem opening file {s}: {}", .{ input_file, err });
        return;
    };
    defer allocator.free(file_contents);

    var line_it = std.mem.split(u8, file_contents, "\n");
    while (line_it.next()) |line| {
        if (line.len == 0) break;

        std.log.info("{s}", .{line[0..]});

        switch (line[0]) {
            '$' => {
                const cmd = switch (line[2]) {
                    'l' => ParseState.LSCommand,
                    'c' => ParseState.CDCommand,
                    else => @panic("ruh roh"),
                };
                _ = cmd;
            },

            '0'...'9' => {
                // deal with file entry
            },

            'd' => {
                // deal with dir
            },

            else => @panic("ruh roh"),
        }
    }
}
