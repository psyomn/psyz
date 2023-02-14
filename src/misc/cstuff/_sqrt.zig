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
