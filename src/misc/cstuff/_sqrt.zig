const std = @import("std");
const os = std.os;

const C = @cImport({
    @cInclude("math.h");
});

// from the manpage:
//     double sqrt(double x);
//     float sqrtf(float x);
//   this is not possible yet, since it seems 80bit precision for floats is
//   not implemeted yet in zig
//     long double sqrtl(long double x);

fn sqrt(val: f64) f64 {
    return C.sqrt(val);
}

fn sqrtf(val: f32) f32 {
    return C.sqrtf(val);
}

pub fn main() anyerror!void {
    std.log.info("simple example of calling a C function", .{});

    std.log.info("float from C.sqrt(double): {d:.3}", .{sqrt(9.0)});
    std.log.info("float from C.sqrtf(float): {d:.3}", .{sqrtf(16.0)});
}
