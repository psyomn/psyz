// Copyright 2022-2023 Simon Symeonidis / psyomn
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
