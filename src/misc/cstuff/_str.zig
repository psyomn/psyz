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

const std = @import("std");

const C = @cImport({
    @cInclude("string.h");
});

fn dump(str: [*:0]const u8) void {
    var i: usize = 0;
    while (str[i] != 0) {
        std.log.info("- {c} 0x{x}", .{ str[i], str[i] });
        i += 1;
    }
}

fn zstrlen(str: [*:0]const u8) usize {
    // size_t strlen(const char *s);
    return C.strlen(str);
}

fn zstrnlen(str: [*:0]const u8, len: usize) usize {
    // size_t strnlen(const char *s, size_t maxlen);
    return C.strnlen(str, len);
}

pub fn main() anyerror!void {
    std.log.info("string tests with C", .{});

    // const str: [*:0]const u8 = "hello there";
    const str = "hello there";
    dump(str);

    std.log.info("C.strlen: {d}", .{zstrlen(str)});
    std.log.info("C.strlnlen: {d}", .{zstrnlen(str, str.len)});
}
