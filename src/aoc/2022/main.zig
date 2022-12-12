const std = @import("std");
const os = std.os;
const allocator = std.testing.allocator;
const print = std.io.getStdOut().writer().print;

const ds = @import("psy-ds");
const getopt = @import("psy-misc").CGetOpt;

// problems
const aoc_01 = @import("1.zig");

const Session = struct {
    problem: ?u8,
};

fn usage() void {
    std.debug.print("aoc-2022 -p <problem-number>\n", .{});
}

pub fn main() !void {
    var sess = Session{ .problem = null };

    var ret = getopt.getopt(os.argv, "p:h");
    while (ret != -1) : (ret = getopt.getopt(os.argv, "p:h")) {
        switch (@intCast(u8, ret)) {
            'p' => {
                const optarg = getopt.optargAsSlice();
                sess.problem = try std.fmt.parseInt(u8, optarg, 10);
            },
            'h' => {
                usage();
                return;
            },
            '?' => {
                return getopt.GetoptError.BadOpt;
            },
            else => {},
        }
    }

    if (sess.problem) |val| {
        switch (val) {
            1 => aoc_01.run(),
            else => try print("no such problem id", .{}),
        }
    } else {
        usage();
    }
}
