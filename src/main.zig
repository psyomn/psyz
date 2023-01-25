const std = @import("std");

pub fn main() !void {
    checkStructCast();
}

fn checkStructCast() void {
    const data = packed struct {
        a: u8 = 0,
        b: u1 = 0,
        c: u2 = 0,
        d: u3 = 0,
        e: u2 = 0,
        f: u16 = 0,
        g: u32 = 0,
    };

    var dd = data{};

    var values = [_]u8{ 0x0a, 0b1011_0101, 0xab, 0xcd, 0xaa, 0xbb, 0xcc, 0xdd };

    for (values) |i| std.debug.print("{x} ", .{i});
    std.debug.print("\n", .{});

    std.debug.print("struct before: {}\n", .{dd});

    var ptr = std.mem.asBytes(&dd);
    // std.debug.print("{x}", .{ptr[0]});

    std.mem.copy(u8, ptr[0..], values[0..]);
    std.debug.print("struct after: {}\n", .{dd});
}
