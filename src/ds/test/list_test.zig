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
const testing = std.testing;
const allocator = std.testing.allocator;

const list = @import("../list.zig");

test "append" {
    var q = list.List(u8).init(&allocator);
    defer q.destroy();

    try q.append(1);
    try q.append(2);
    try q.append(3);

    try testing.expect(q.head.?.data == 1);
    try testing.expect(q.head.?.next.?.data == 2);
    try testing.expect(q.head.?.next.?.next.?.data == 3);
}

test "create list example" {
    var q = list.List(u8).init(&allocator);
    defer q.destroy();
}

test "add items and seek" {
    var q = list.List(u8).init(&allocator);
    defer q.destroy();

    try q.append(1);
    if (q.getHead()) |head| {
        try testing.expect(head.data == 1);
    }

    try q.append(2);
    _ = q.seek(2) orelse return error.TestExpectSeek;

    try q.append(3);
    _ = q.seek(3) orelse return error.TestExpectSeek;

    try q.append(4);
    _ = q.seek(4) orelse return error.TestExpectSeek;
}

test "insert after" {
    var q = list.List(u8).init(&allocator);
    defer q.destroy();

    try q.append(1);
    try q.append(2);
    try q.append(4);

    try q.insertAfter(2, 3);

    try testing.expect(q.seek(2).?.next.?.data == 3);
}
