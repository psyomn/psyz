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
