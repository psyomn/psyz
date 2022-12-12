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
                var dat = try self.allocator.alloc(T, self.cap);
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
