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

const st = @import("stack.zig");

pub fn Tree(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            children: ?[]Node = null,
        };

        root: ?*Node,
        cursor: ?*Node,
        allocator: std.mem.Allocator,

        pub fn init(allocator: std.mem.Allocator) Self {
            return .{
                .root = null,
                .cursor = null,
                .allocator = allocator,
            };
        }

        pub fn insert(self: *Self, item: T) !void {
            if (self.root) |_| {} else {
                self.root = try self.allocator.create(Node);
                self.cursor = self.root;
                self.cursor.?.data = item;
                return;
            }

            if (self.cursor.?.children) |children| {
                var chs = try self.allocator.realloc(children, children.len + 1);
                chs[chs.len - 1].data = item;
                chs[chs.len - 1].children = null;
                self.cursor.?.children = chs;
            } else {
                var chs = try self.allocator.alloc(Node, 1);
                chs[0].data = item;
                chs[0].children = null;
                self.cursor.?.children = chs;
            }
        }

        fn dealloc(self: *Self) !void {
            var root = self.root orelse return;

            var stack = st.Stack([]Node).init(self.allocator);
            defer stack.destroy();

            if (root.children) |children| try stack.push(children);

            var it: []Node = undefined;
            while (stack.len > 0) {
                it = stack.pop();

                for (it) |item|
                    if (item.children) |cs| try stack.push(cs);

                self.allocator.free(it);
            }

            self.allocator.destroy(root);
            self.root = undefined;
            self.cursor = undefined;
        }

        pub fn destroy(self: *Self) void {
            self.dealloc() catch |err| {
                std.log.err("unrecoverable crash during cleanup: {}", .{err});
                @panic("error cleaning up tree.zig");
            };
        }
    };
}
