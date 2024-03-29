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

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        data: []T,
        len: usize,
        cap: usize,
        dirty: bool,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .len = 0,
                .cap = 1 << 4,
                .data = undefined,
                .allocator = allocator,
                .dirty = false,
            };
        }

        pub fn push(self: *Self, item: T) !void {
            if (self.len == 0 and !self.dirty) {
                self.data = try self.allocator.alloc(T, self.cap);
                self.dirty = true;
            }

            self.len += 1;

            if (self.len > self.cap) {
                self.cap <<= 1;
                self.data = try self.allocator.realloc(self.data, self.cap);
            }

            self.data[self.len - 1] = item;
        }

        pub fn pop(self: *Self) T {
            const curr_index = self.index();
            const ret = self.data[curr_index];

            self.data[curr_index] = undefined;
            self.len -= 1;

            return ret;
        }

        pub fn peek(self: Self) T {
            return self.data[self.len - 1];
        }

        pub fn destroy(self: *Self) void {
            if (!self.dirty) return;
            self.allocator.free(self.data);
        }

        pub fn index(self: Self) usize {
            return self.len - 1;
        }
    };
}
