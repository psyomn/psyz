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
