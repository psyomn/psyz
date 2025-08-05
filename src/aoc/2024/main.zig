const std = @import("std");

pub fn main() !void {
    const probs = [_](*const fn () void){
        @import("1.zig").run,
        @import("2.zig").run,
        @import("3.zig").run,
        @import("4.zig").run,
        @import("5.zig").run,
    };

    for (probs, 0..) |p, ix| {
        std.log.debug("==== {}", .{ix + 1});
        p();
    }
}
