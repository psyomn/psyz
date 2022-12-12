pub const C = @cImport({
    @cInclude("getopt.h");
});

const CStr = @cImport({
    @cInclude("string.h");
});

const std = @import("std");

pub const GetoptError = error{
    NotFound,
    BadOpt,
};

fn _getopt(argc: usize, argv: [*]const [*]u8, optstring: [*:0]const u8) i32 {
    // int getopt(int argc, char *const argv[], const char *optstring);
    const c_argc: c_int = @intCast(c_int, argc);
    const gret: c_int = C.getopt(c_argc, argv, optstring);

    return @intCast(i32, gret);
}

pub fn getopt(argv: [][*:0]u8, optstring: [*:0]const u8) i32 {
    const char_ret = _getopt(
        argv.len,
        @ptrCast([*]const [*]u8, argv),
        optstring,
    );

    return char_ret;
}

pub fn optargAsSlice() []u8 {
    return std.mem.span(C.optarg);
}

pub fn optargLen() usize {
    return CStr.strlen(C.optarg);
}
