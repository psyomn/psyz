const std = @import("std");

const CX11 = @cImport({
    @cInclude("X11/Xlib.h");
    @cInclude("X11/Xutil.h");
});

const CTime = @cImport({
    @cInclude("time.h");
});

const session = struct {
    interval_seconds: usize = 5,
};

const utils = @import("psy-utils");

const allocator = std.heap.page_allocator;

pub fn main() !void {
    const sess = session{};
    std.log.info("started dsu {s}", .{utils.Version});
    std.log.info("tick interval: {d} seconds", .{sess.interval_seconds});

    const engravers = [_](*const fn ([]u8) usize){
        engraveCalendar,
        engraveReminder,
        engraveBattery,
        engraveDate,
    };

    while (true) {
        std.time.sleep(std.time.ns_per_s * sess.interval_seconds);

        // 1024 is a gross exaggeration
        var buffer: [1024]u8 = .{0} ** 1024;
        var lastSz: usize = 0;
        for (engravers) |e| lastSz += e(buffer[lastSz..]);

        const display: ?*CX11.Display = CX11.XOpenDisplay(0);

        if (display) |d| {
            const screen: c_int = CX11.DefaultScreen(d);
            const root: CX11.Window = CX11.RootWindow(d, screen);

            if (root != 0)
                CX11.Xutf8SetWMProperties(d, root, buffer[0..], 0, 0, 0, 0, 0, 0)
            else
                std.log.err("no root window found", .{});

            if (CX11.XCloseDisplay(d) != 0)
                std.log.err("could not close display", .{});
        } else {
            std.log.err("no display found", .{});
            continue;
        }
    }
}

fn engraveDate(buf: []u8) usize {
    var now = CTime.time(null);
    const tm: CTime.tm = CTime.localtime(&now).*;

    // the casts are required because I can't figure out how to disable the
    // sign (and reading the std lib it doesn't quite look like you can do this
    // if something is signed).
    const result = std.fmt.bufPrint(buf, "[{d:0>2}:{d:0>2}][{d:0>2}/{d:0>2}/{d:0>2}]", .{
        @as(u32, @intCast(tm.tm_hour)),
        @as(u32, @intCast(tm.tm_min)),
        @as(u32, @intCast(tm.tm_mday)),
        @as(u32, @intCast(tm.tm_mon + 1)),
        @as(u32, @intCast(tm.tm_year + 1900)),
    }) catch unreachable;

    return result.len;
}

fn engraveBattery(buf: []u8) usize {
    var batteries = batteryProcFS();
    defer batteries.deinit();

    std.log.info("battery-info: {any}", .{batteries.items});

    var total_capacity: usize = 0;
    for (batteries.items) |bat| total_capacity += bat.capacity;
    total_capacity /= batteries.items.len;

    const result = std.fmt.bufPrint(buf[0..], "[BAT:{d:0>3}]", .{
        total_capacity,
    }) catch unreachable;

    return result.len;
}

fn engraveCalendar(buf: []u8) usize {
    // This was from the small storage project I did.  I'm not
    // sure if I want to do it again in zig but we can see!
    @memcpy(buf[0..], "[]");
    return 2;
}

fn engraveReminder(buf: []u8) usize {
    const to_copy = [_:0]u8{
        '[',  0xe6,
        0xad, 0xa3,
        0xe7, 0xbe,
        0xa9, ']',
    };

    @memcpy(buf[0..], to_copy[0..]);

    return to_copy.len;
}

const BatteryInfo = struct { capacity: u8 = 0 };
fn batteryProcFS() std.ArrayList(BatteryInfo) {
    var arr = std.ArrayList(BatteryInfo).init(allocator);
    var count: usize = 0;

    blk: while (true) : (count += 1) {
        var bat_path: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const res = std.fmt.bufPrint(bat_path[0..], "/sys/class/power_supply/BAT{d}/capacity", .{count}) catch unreachable;

        var fh = std.fs.openFileAbsolute(res, .{ .mode = .read_only }) catch break :blk;
        defer fh.close();

        var contents: [5]u8 = .{0} ** 5;
        const rbytes = fh.readAll(contents[0..]) catch |err| {
            std.log.err("could not read procfs contents: {}", .{err});
            continue;
        };
        const trimmed = contents[0 .. rbytes - 1];

        const capacity = std.fmt.parseUnsigned(u8, trimmed, 10) catch |err| {
            std.log.warn("could not read capacity from {s}: {}", .{ trimmed, err });
            continue;
        };

        arr.append(BatteryInfo{ .capacity = capacity }) catch {
            std.log.err("ran out of memory when trying to insert battery info", .{});
            break :blk;
        };
    }

    return arr;
}
