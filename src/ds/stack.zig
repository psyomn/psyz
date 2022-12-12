const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        data: []T,
        len: usize,
        cap: usize,
        dirty: bool,
        allocator: *const Allocator,

        pub fn init(allocator: *const Allocator) Self {
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
            if (!self.dirty) {
                return;
            }

            self.allocator.free(self.data);
        }

        pub fn index(self: Self) usize {
            return self.len - 1;
        }
    };
}
