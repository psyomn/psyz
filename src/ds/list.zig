const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn List(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Node = struct {
            data: T,
            next: ?*Node,
        };

        head: ?*Node,
        allocator: *const Allocator,

        pub fn init(allocator: *const Allocator) Self {
            return .{
                .head = null,
                .allocator = allocator,
            };
        }

        pub fn seek(self: Self, target: T) ?*Node {
            var it: ?*Node = self.head;
            while (it) |n| : (it = n.next) {
                if (n.data == target) {
                    return n;
                }
            }

            return null;
        }

        pub fn getHead(self: Self) ?*const Node {
            return self.head;
        }

        pub fn insertAfter(self: *Self, target: T, item: T) !void {
            var found = self.seek(target) orelse return error.ListNotFound;

            var maybe_next: ?*Node = found.next;

            var new_node = try self.allocator.create(Node);
            new_node.data = item;

            found.next = new_node;
            new_node.next = maybe_next;
        }

        pub fn append(self: *Self, item: T) !void {
            if (self.head) |_| {} else {
                var h = try self.allocator.create(Node);
                h.data = item;
                h.next = null;
                self.head = h;
                return;
            }

            var it: ?*Node = self.head;
            while (it) |n| {
                if (n.next) |_| {
                    it = n.next;
                } else {
                    break;
                }
            }

            var node = try self.allocator.create(Node);
            node.data = item;
            node.next = null;
            it.?.next = node;
        }

        pub fn destroy(self: *Self) void {
            var it: ?*Node = self.head;
            while (it) |n| {
                it = n.next;
                self.allocator.destroy(n);
            }
        }
    };
}
