const std = @import("std");
const http = std.http;
const net = std.net;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    //    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    //    const alloc = gpa.allocator();
    //    defer if (gpa.deinit() == .leak) @panic("leaks will drown us all");

    //    const addr = try net.Address.parseIp("0.0.0.0", 9090);

    //    // this is not optimal: https://github.com/ziglang/zig/issues/4082
    //    // this is minimum page size, and not necessarily the optimum page size.
    //    var srv_buf: [std.mem.page_size]u8 = .{0} ** std.mem.page_size;
    //    const conn = try addr.listen(.{ .reuse_address = true });
    //    var server = http.Server.init(conn, &srv_buf);

    //    defer server.deinit();

    //    try server.listen(addr);

    //    while (true) {
    //        var resp = try server.accept(.{ .allocator = alloc });
    //        defer resp.deinit();
    //        defer _ = resp.reset();
    //        try resp.wait();

    //        var buf: [512]u8 = undefined;
    //        @memset(buf[0..], 0);

    //        std.debug.print("{s}\n", .{resp.request.target});
    //        std.debug.print("{}\n", .{resp.request});

    //        _ = try resp.readAll(&buf);
    //        std.debug.print("{s}", .{buf[0..]});

    //        resp.status = http.Status.ok;
    //        try resp.do();
    //    }
}
