// Copyright 2022-2023 Simon Symeonidis / psyomn
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

const std = @import("std");
const common = @import("common.zig");

pub fn run() void {
    const allocator = std.heap.page_allocator;

    common.mkline("AOC 2: 1");

    const path = "src/aoc/2022/input/2.txt";
    var buf = common.fileToBuf(path, allocator) catch |err| {
        std.debug.print("can't open file {s}: {}\n", .{ path, err });
        return;
    };
    defer allocator.free(buf);

    var score: u64 = 0;
    var score2: u64 = 0;

    const table = [_][3]u8{
        //R  P  S
        .{ 3, 0, 6 }, // R
        .{ 6, 3, 0 }, // P
        .{ 0, 6, 3 }, // S
    };

    const outcome_table = [_][3]u8{
        //  L    D    W
        .{ 'Z', 'X', 'Y' }, // R other
        .{ 'X', 'Y', 'Z' }, // P
        .{ 'Y', 'Z', 'X' }, // S
    };

    var it = std.mem.split(u8, buf, "\n");
    while (it.next()) |tok| {
        if (tok.len != 3) continue;

        const other = tok[0];
        const me = tok[2];

        switch (me) {
            'X', 'Y', 'Z' => score += (me - 'X' + 1),
            else => @panic("bad input"),
        }

        score += table[me - 'X'][other - 'A'];

        // part 2
        const play_what = outcome_table[other - 'A'][me - 'X'];
        switch (play_what) {
            'X', 'Y', 'Z' => score2 += (play_what - 'X' + 1),
            else => @panic("bad input"),
        }
        score2 += table[play_what - 'X'][other - 'A'];
    }

    std.log.info("result  : {}", .{score});
    std.log.info("result 2: {}", .{score2});
}
