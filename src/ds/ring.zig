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

pub fn Ring(comptime T: type) type {
    return struct {
        const Self = @This();

        allocator: std.mem.Allocator,
        data: ?[]T,
        cap: usize,
        cursor: usize,

        pub fn init(allocator: Allocator, cap: usize) Self {
            return .{
                .allocator = allocator,
                .data = null,
                .cap = cap,
                .cursor = 0,
            };
        }

        fn bootstrap(self: *Self) !void {
            self.data = try self.allocator.alloc(T, self.cap);
        }

        pub fn insert(self: *Self, item: T) !void {
            if (self.data) |_| {} else try self.bootstrap();

            if (self.data) |dat| {
                self.cursor = (self.cursor + 1) % self.cap;
                dat[self.cursor] = item;
            }
        }

        pub fn at(self: Self, ix: usize) *const T {
            return &self.data.?[(self.cursor + ix) % self.cap];
        }

        pub fn destroy(self: *Self) void {
            if (self.data) |dat| {
                self.allocator.free(dat);
            }
        }
    };
}
