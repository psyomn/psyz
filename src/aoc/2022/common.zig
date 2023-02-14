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
