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
const allocator = std.testing.allocator;

const stack = @import("../stack.zig");

test "init a stack" {
    var st = stack.Stack(u8).init(allocator);
    defer st.destroy();
}

test "push one" {
    var st = stack.Stack(u8).init(allocator);
    defer st.destroy();
    try st.push(1);
}

test "push a few items in stack" {
    var st = stack.Stack(u8).init(allocator);
    defer st.destroy();

    var i: u8 = 0;
    const n = 10;
    while (i < n) : (i += 1) {
        try st.push(i);
    }

    try std.testing.expect(st.peek() == 9);
}

test "pop a few items" {
    var st = stack.Stack(u8).init(allocator);
    defer st.destroy();

    var i: u8 = 0;
    var n: u8 = 10;

    while (i < n) : (i += 1) {
        try st.push(i);
    }

    const expect_9 = st.pop();
    const expect_8 = st.pop();
    const expect_7 = st.pop();

    try std.testing.expectEqual(expect_9, @as(u8, 9));
    try std.testing.expectEqual(expect_8, @as(u8, 8));
    try std.testing.expectEqual(expect_7, @as(u8, 7));
}

test "insert stack structs" {
    const Person = struct {
        name: []const u8,
        age: u8,
    };

    var ps = [_]Person{
        .{ .name = "john", .age = 12 },
        .{ .name = "amy", .age = 13 },
        .{ .name = "dan", .age = 14 },
    };

    var st = stack.Stack(Person).init(allocator);
    defer st.destroy();

    for (ps) |p| {
        try st.push(p);
    }
}

test "insert malloc'd structs" {
    const Person = struct {
        name: []const u8,
        age: u8,
    };

    var p1 = try allocator.create(Person);
    defer allocator.destroy(p1);
    p1.name = "john";
    p1.age = 12;

    var p2 = try allocator.create(Person);
    defer allocator.destroy(p2);
    p2.name = "amy";
    p2.age = 13;

    var st = stack.Stack(*Person).init(allocator);
    defer st.destroy();

    try st.push(p1);
    try st.push(p2);
}

test "push 10 pop 10 dealloc" {
    var i: u32 = 0;
    var j: u32 = 100;

    var st = stack.Stack(u32).init(allocator);
    defer st.destroy();

    while (i < j) : (i += 1) {
        try st.push(i);
    }

    i = 0;
    while (i < j) : (i += 1) {
        _ = st.pop();
    }
}

test "accordion from hell" {
    var i: u32 = 0;
    var k: u32 = 0;
    const j: u32 = 100;

    var st = stack.Stack(u32).init(allocator);
    defer st.destroy();

    while (k < 100) : (k += 1) {
        i = 0;
        while (i < j) : (i += 1) {
            try st.push(i);
        }

        i = 0;
        while (i < j) : (i += 1) {
            _ = st.pop();
        }
    }
}
