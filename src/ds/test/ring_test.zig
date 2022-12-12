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
