const std = @import("std");

const dynarr = @import("../dynarr.zig");

const allocator = std.testing.allocator;

test "dynamic arrays with primitive types" {
    var da8 = dynarr.DynArr(u8).init(&allocator);
    defer da8.destroy();

    var da16 = dynarr.DynArr(u16).init(&allocator);
    defer da16.destroy();

    try std.testing.expectEqual(@as(usize, 0), da8.numItems());
    try std.testing.expectEqual(@as(usize, 0), da16.numItems());

    var i: u8 = 0;
    while (i < 10) : (i += 1) {
        try da8.add(i);
    }

    i = 0;
    while (i < 10) : (i += 1) {
        try da16.add(3);
    }

    // for (da8.data) |el| {
    //     std.log.warn("da8: {}", .{el});
    // }
}

test "dynamic arrays grow properly" {
    var da8 = dynarr.DynArr(u32).init(&allocator);
    defer da8.destroy();

    const orig_cap = da8.cap;

    try da8.add(123);
    try std.testing.expectEqual(da8.cap, orig_cap);

    var count: usize = 0;
    while (count < orig_cap) : (count += 1) {
        try da8.add(0xcc);
    }

    try da8.add(0xdd);
    try std.testing.expectEqual(orig_cap << 1, da8.cap);
}

test "dynamic array takes a struct" {
    const Person = struct {
        age: u8,
        name: []const u8,
    };

    const john = Person{ .age = 21, .name = "derp" };
    var dap = dynarr.DynArr(Person).init(&allocator);
    defer dap.destroy();

    try dap.add(john);

    try std.testing.expectEqual(@as(usize, 21), dap.at(0).age);
}
