const std = @import("std");

pub fn main() !void {
    const probs = [_](*const fn () void){
        @import("1.zig").run,
        @import("2.zig").run,
    };

    if (std.os.argv.len == 1) {
        for (probs, 0..) |p, ix| {
            std.log.debug("==== {}", .{ix});
            p();
        }
    } else if (std.os.argv.len > 1) {
        // TODO
    }
}
