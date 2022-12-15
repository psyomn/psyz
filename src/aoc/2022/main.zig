const std = @import("std");
const os = std.os;

const ds = @import("psy-ds");
const getopt = @import("psy-misc").CGetOpt;
const curl = @import("psy-misc").CCurl;

// problems
const common = @import("common.zig");
const aoc_01 = @import("1.zig");
const aoc_02 = @import("2.zig");
const aoc_03 = @import("3.zig");

const Session = struct {
    problem: ?usize,
};

fn fetch() void {
    const allocator = std.heap.c_allocator;

    const etl = struct {
        from: []const u8,
        to: []const u8,
    };

    var files = [_]etl{ .{
        .from = "https://gist.githubusercontent.com/psyomn/e991f6925771670e697d6e0166745377/raw/92795cc0dedb18d6fba8ba4cb1f71ea5b9873a1f/aoc-2022-1.txt",
        .to = "src/aoc/2022/input/1.txt",
    }, .{
        .from = "https://gist.githubusercontent.com/psyomn/e991f6925771670e697d6e0166745377/raw/6277e3a078bc1346045047dad3f5783a036557e5/aoc-2022-2.txt",
        .to = "src/aoc/2022/input/2.txt",
    }, .{
        .from = "https://gist.githubusercontent.com/psyomn/e991f6925771670e697d6e0166745377/raw/c26cd8ccafdbf4c7332512e2aaf27cbf68b6d717/aoc-2022-3.txt",
        .to = "src/aoc/2022/input/3.txt",
    } };

    for (files) |file| {
        std.debug.print("fetching: {s}...\n", .{file.from});

        const ret = curl.get(file.from[0..]) catch |err| {
            std.debug.print("error: {}", .{err});
            continue;
        };
        defer allocator.free(ret);

        common.writeBuf(file.to, ret) catch |err| {
            std.debug.print("could not write file {s}: {}\n", .{ file.to, err });
            continue;
        };
    }
}

fn usage() void {
    std.debug.print("aoc-2022 -p <problem-number> run aoc problem\n", .{});
    std.debug.print("aoc-2022 -g will fetch the data\n", .{});
}

pub fn main() !void {
    var sess = Session{ .problem = null };

    var ret = getopt.getopt(os.argv, "p:hg");
    while (ret != -1) : (ret = getopt.getopt(os.argv, "p:hg")) {
        switch (@intCast(u8, ret)) {
            'p' => {
                const optarg = getopt.optargAsSlice();
                sess.problem = try std.fmt.parseInt(u8, optarg, 10);
            },
            'g' => {
                std.debug.print("getting data...\n", .{});
                fetch();
                return;
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

    const fnarr = [_](fn () void){
        aoc_01.run,
        aoc_02.run,
        aoc_03.run,
    };

    if (sess.problem) |val| {
        switch (val) {
            0...fnarr.len => |idx| fnarr[idx](),
            else => std.debug.print("no such problem id\n", .{}),
        }
    } else {
        usage();
    }
}
