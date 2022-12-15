const std = @import("std");

pub fn mkline(str: []const u8) void {
    std.debug.print("= {s} ======================\n", .{str});
}

pub fn fileToBuf(path: []const u8, allocator: std.mem.Allocator) ![]u8 {
    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    const stat = try file.stat();
    const sz = stat.size;

    return try file.reader().readAllAlloc(allocator, sz);
}

pub fn writeBuf(path: []const u8, buf: []const u8) !void {
    const file = try std.fs.cwd().createFile(path, .{});
    defer file.close();

    return try file.writeAll(buf);
}
