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
const ds = @import("psy-ds");

const State = struct {
    stacks: [9]ds.Stack(u8),
    result: [9]u8,
};

pub fn run() void {
    part1();
    part2();
}

fn part1() void {
    common.mkline("AOC 5: 1");

    const allocator = std.heap.page_allocator;
    var state = State{
        .stacks = .{ds.Stack(u8).init(allocator)} ** 9,
        .result = .{0} ** 9,
    };
    for (&state.stacks) |*stack| {
        defer stack.*.destroy();
    }

    const filepath = "src/aoc/2022/input/5.txt";
    const buf = common.fileToBuf(filepath, allocator) catch |err| {
        std.log.info("could not open file {s}: {}", .{ filepath, err });
        return;
    };
    defer allocator.free(buf);

    // parse crates
    var it = std.mem.split(u8, buf, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;

        switch (line[1]) {
            '0'...'9' => continue,
            else => {},
        }

        var cur: usize = 1;
        while (cur < line.len) : (cur += 4) {
            switch (line[cur]) {
                'A'...'Z' => |letter| {
                    // std.log.info("letter: {c} at {d}", .{ val, (cur - 1) / 4 });
                    state.stacks[(cur - 1) / 4].push(letter) catch unreachable;
                },
                ' ' => continue,
                else => @panic("uh oh"),
            }
        }
    }

    for (state.stacks) |stack| {
        // need to reverse due to parsing order
        std.mem.reverse(u8, stack.data[0..stack.len]);
    }

    // parse movement
    while (it.next()) |line| {
        if (line.len == 0) break;

        var mit = std.mem.split(u8, line, " ");

        _ = mit.next(); // move
        const num_move: i64 = std.fmt.parseInt(i64, mit.next().?, 10) catch unreachable;
        _ = mit.next(); // from
        const from: usize = std.fmt.parseInt(usize, mit.next().?, 10) catch unreachable;
        _ = mit.next(); // to
        const to: usize = std.fmt.parseInt(usize, mit.next().?, 10) catch unreachable;

        var count: usize = 0;
        while (count < num_move) : (count += 1) {
            state.stacks[to - 1].push(state.stacks[from - 1].pop()) catch unreachable;
        }
    }

    for (state.stacks) |stack| {
        std.log.info("{s}", .{stack.data});
    }

    for (state.stacks, 0..) |stack, i| {
        state.result[i] = stack.peek();
    }
    std.log.info("result: {s}", .{state.result[0..]});
}

fn part2() void {
    common.mkline("AOC 5: 2");

    const allocator = std.heap.page_allocator;
    var state = State{
        .stacks = .{ds.Stack(u8).init(allocator)} ** 9,
        .result = .{0} ** 9,
    };
    for (&state.stacks) |*stack| {
        defer stack.*.destroy();
    }

    const filepath = "src/aoc/2022/input/5.txt";
    const buf = common.fileToBuf(filepath, allocator) catch |err| {
        std.log.info("could not open file {s}: {}", .{ filepath, err });
        return;
    };
    defer allocator.free(buf);

    // parse crates
    var it = std.mem.split(u8, buf, "\n");
    while (it.next()) |line| {
        if (line.len == 0) break;

        switch (line[1]) {
            '0'...'9' => continue,
            else => {},
        }

        var cur: usize = 1;
        while (cur < line.len) : (cur += 4) {
            switch (line[cur]) {
                'A'...'Z' => |letter| {
                    // std.log.info("letter: {c} at {d}", .{ val, (cur - 1) / 4 });
                    state.stacks[(cur - 1) / 4].push(letter) catch unreachable;
                },
                ' ' => continue,
                else => @panic("uh oh"),
            }
        }
    }

    for (state.stacks) |stack| {
        // need to reverse due to parsing order
        std.mem.reverse(u8, stack.data[0..stack.len]);
    }

    // parse movement
    while (it.next()) |line| {
        if (line.len == 0) break;

        var mit = std.mem.split(u8, line, " ");

        _ = mit.next(); // move
        const num_move: i64 = std.fmt.parseInt(i64, mit.next().?, 10) catch unreachable;
        _ = mit.next(); // from
        const from: usize = std.fmt.parseInt(usize, mit.next().?, 10) catch unreachable;
        _ = mit.next(); // to
        const to: usize = std.fmt.parseInt(usize, mit.next().?, 10) catch unreachable;

        var st = ds.Stack(u8).init(allocator);
        defer st.destroy();

        var count: usize = 0;
        while (count < num_move) : (count += 1) {
            st.push(state.stacks[from - 1].pop()) catch unreachable;
        }

        count = 0;
        while (count < num_move) : (count += 1) {
            state.stacks[to - 1].push(st.pop()) catch unreachable;
        }
    }

    for (state.stacks) |stack| {
        std.log.info("{s}", .{stack.data});
    }

    for (state.stacks, 0..) |stack, i| {
        state.result[i] = stack.peek();
    }
    std.log.info("result: {s}", .{state.result[0..]});
}
