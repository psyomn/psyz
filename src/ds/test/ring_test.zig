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

const ring = @import("../ring.zig");

test "create ring" {
    var r = ring.Ring(u8).init(allocator, 3);
    defer r.destroy();
}

test "insert into ring" {
    var r = ring.Ring(u8).init(allocator, 3);
    defer r.destroy();

    try r.insert(1);
    try r.insert(2);
    try r.insert(3);
}

test "rollover" {
    var r = ring.Ring(u8).init(allocator, 3);
    defer r.destroy();

    try r.insert('h');
    try r.insert('e');
    try r.insert('l');
    try r.insert('l');
    try r.insert('o');

    if (r.data) |dat| {
        try std.testing.expectEqual(dat[0], 'l');
        try std.testing.expectEqual(dat[1], 'l');
        try std.testing.expectEqual(dat[2], 'o');
    }
}
