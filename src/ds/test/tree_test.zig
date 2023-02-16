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

const tree = @import("../tree.zig");

test "init a tree" {
    var tr = tree.Tree(u8).init(allocator);
    defer tr.destroy();
}

test "insert" {
    var tr = tree.Tree(u8).init(allocator);
    defer tr.destroy();

    for ("hello") |c| try tr.insert(c);
}

test "insert move cursor" {
    var tr = tree.Tree(u8).init(allocator);
    defer tr.destroy();

    for ("hello") |c| try tr.insert(c);

    var cursor = &tr.root.?.children.?[1];
    tr.cursor = cursor;

    for ("hello") |c| try tr.insert(c);

    const expectEqual = std.testing.expectEqual;
    const rootc = tr.root.?.children.?;

    try expectEqual(tr.root.?.data, 'h');
    try expectEqual(rootc.len, 4);
    try expectEqual(rootc[0].data, 'e');
    try expectEqual(rootc[1].data, 'l');
    try expectEqual(rootc[2].data, 'l');
    try expectEqual(rootc[3].data, 'o');

    try expectEqual(rootc[1].children.?.len, 5);
    try expectEqual(rootc[1].children.?[0].data, 'h');
    try expectEqual(rootc[1].children.?[1].data, 'e');
    try expectEqual(rootc[1].children.?[2].data, 'l');
    try expectEqual(rootc[1].children.?[3].data, 'l');
    try expectEqual(rootc[1].children.?[4].data, 'o');
}
