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

const bintree = @import("../bintree.zig");

pub fn cmpint(a: u32, b: u32) bool {
    return a > b;
}

test "create bintree" {
    var bt = bintree.BinTree(u32).init(allocator, cmpint);
    try bt.destroy();
}

test "insert" {
    var bt = bintree.BinTree(u32).init(allocator, cmpint);

    try bt.insert(10);

    try bt.insert(5);
    try bt.insert(15);
    try bt.insert(8);
    try bt.insert(17);

    // 10-15-17
    // 5
    //   8

    try testing.expect(bt.root.?.data == 10);
    try testing.expect(bt.root.?.right.?.data == 15);
    try testing.expect(bt.root.?.right.?.right.?.data == 17);

    try bt.destroy();
}
