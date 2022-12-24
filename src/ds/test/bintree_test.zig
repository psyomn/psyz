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
