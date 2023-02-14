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

pub fn BinTree(comptime T: type) type {
    return struct {
        const Self = @This();
        root: ?*Node,
        cmpfn: *const fn (a: T, b: T) bool,
        allocator: std.mem.Allocator,

        pub const Node = struct {
            left: ?*Node,
            right: ?*Node,
            data: T,

            const NodeSelf = @This();

            pub fn mk(alloc: std.mem.Allocator, data: T) !*NodeSelf {
                var ret = try alloc.create(NodeSelf);
                ret.left = null;
                ret.right = null;
                ret.data = data;
                return ret;
            }
        };

        pub fn init(allocator: std.mem.Allocator, cmpfn: *const fn (a: T, b: T) bool) Self {
            return .{
                .root = null,
                .allocator = allocator,
                .cmpfn = cmpfn,
            };
        }

        pub fn insert(self: *Self, item: T) !void {
            if (self.root) |_| {} else {
                var node = try Node.mk(self.allocator, item);
                self.root = node;
                return;
            }

            var it: ?*Node = self.root;

            while (it) |n| {
                if (self.cmpfn(n.data, item)) {
                    if (n.left) |_| {
                        it = n.left;
                    } else {
                        var node = try Node.mk(self.allocator, item);
                        n.left = node;
                        break;
                    }
                } else {
                    if (n.right) |_| {
                        it = n.right;
                    } else {
                        var node = try Node.mk(self.allocator, item);
                        n.right = node;
                        break;
                    }
                }
            }
        }

        pub fn destroy(self: *Self) !void {
            var root = self.root orelse return;

            var stack = st.Stack(*Node).init(self.allocator);
            defer stack.destroy();
            try stack.push(root);

            var it: *Node = undefined;
            while (stack.len > 0) {
                it = stack.pop();
                if (it.left) |l| {
                    try stack.push(l);
                }
                if (it.right) |r| {
                    try stack.push(r);
                }
                self.allocator.destroy(it);
            }
        }
    };
}
