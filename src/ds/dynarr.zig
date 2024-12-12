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
const Allocator = std.mem.Allocator;

pub fn DynArr(comptime T: type) type {
    return struct {
        data: []T,
        len: usize,
        cap: usize,
        allocator: *const Allocator,

        const Self = @This();

        pub fn numItems(self: Self) usize {
            return self.len;
        }

        pub fn at(self: *Self, index: usize) *const T {
            return &self.data[index];
        }

        pub fn add(self: *Self, item: T) !void {
            if (self.len == 0) {
                const dat = try self.allocator.alloc(T, self.cap);
                self.len += 1;
                self.data = dat;
                self.data[self.len - 1] = item;
                return;
            }

            self.len += 1;
            if (self.len > self.cap) {
                self.data = try self.allocator.realloc(self.data, self.cap << 1);
                self.cap <<= 1;
            }
            self.data[self.len - 1] = item;
        }

        pub fn init(allocator: *const Allocator) Self {
            return .{
                .data = undefined,
                .len = 0,
                .cap = 1 << 4,
                .allocator = allocator,
            };
        }

        pub fn destroy(self: *Self) void {
            if (self.len == 0) {
                return;
            }

            self.allocator.free(self.data);
        }
    };
}
