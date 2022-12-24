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

    for ("hello") |c| {
        try tr.insert(c);
    }
}

test "insert move cursor" {
    var tr = tree.Tree(u8).init(allocator);
    defer tr.destroy();

    for ("hello") |c| {
        try tr.insert(c);
    }

    var cursor = &tr.root.?.children.?[1];
    tr.cursor = cursor;

    for ("hello") |c| {
        try tr.insert(c);
    }

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
