const std = @import("std");

const st = @import("stack.zig");

pub fn BinTree(comptime T: type) type {
    return struct {
        const Self = @This();
        root: ?*Node,
        cmpfn: fn (a: T, b: T) bool,
        allocator: *const std.mem.Allocator,

        pub const Node = struct {
            left: ?*Node,
            right: ?*Node,
            data: T,

            const NodeSelf = @This();

            pub fn mk(alloc: *const std.mem.Allocator, data: T) !*NodeSelf {
                var ret = try alloc.create(NodeSelf);
                ret.left = null;
                ret.right = null;
                ret.data = data;
                return ret;
            }
        };

        pub fn init(allocator: *const std.mem.Allocator, cmpfn: fn (a: T, b: T) bool) Self {
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
