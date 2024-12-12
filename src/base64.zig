// Copyright 2023 Simon Symeonidis / psyomn
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

// consulted some of: rfc4648

// You probably shouldn't be using this.  I have a personal use for it; use any
// other implementation from coreutils, busybox, or other frens.  NB: lib std
// has base64 as well.

const std = @import("std");

const version = @import("psy-utils").Version;

const table = [_]u8{
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O',
    'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd',
    'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's',
    't', 'u', 'v', 'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7',
    '8', '9', '+', '/',
};

var itable = [_]u8{
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  62, 0,  0,  0,  63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 0,  0,  0,  0,  0,  0,
    0,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9,  10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 0,  0,  0,  0,  0,
    0,  26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
    0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,  0,
};

const padding = '=';

const Session = struct {
    decode: bool = false,
    help: bool = false,
    verbose: u8 = 0,
    of: std.fs.File = undefined,
    iff: std.fs.File = undefined,

    pub fn fromArgs(stdout: std.fs.File, stdin: std.fs.File) !Session {
        var ret = Session{ .of = stdout, .iff = stdin };
        var args = std.process.args();
        _ = args.skip(); // name

        while (args.next()) |arg| {
            if (arg.len >= 2 and arg[0] == '-') {
                ret.decode = ret.decode or std.mem.eql(u8, arg, "-d");
                ret.verbose += if (std.mem.eql(u8, arg, "-v")) 1 else 0;
                ret.help = ret.help or std.mem.eql(u8, arg, "-h");
                continue;
            }

            if (std.mem.eql(u8, arg, "-")) {
                ret.of = stdout;
            } else {
                const fh = try std.fs.cwd().createFile(arg, .{});
                ret.of = fh;
            }
            break;
        }

        return ret;
    }

    pub fn deinit(self: *Session) void {
        self.of.close();
    }
};

fn encode(buf: []const u8, out: std.fs.File) !void {
    const writer = out.writer();

    var count: usize = 0;

    while (count < buf.len) : (count += 3) {
        const ok1 = count + 1 < buf.len;
        const ok2 = count + 2 < buf.len;
        const n0 = if (count < buf.len) buf[count] else 0;
        const n1 = if (ok1) buf[count + 1] else 0;
        const n2 = if (ok2) buf[count + 2] else 0;

        const shl = std.math.shl;
        const triad: u24 =
            shl(u24, (n0), 16) |
            shl(u24, (n1), 8) |
            @as(u24, (n2));

        const shr = std.math.shr;
        try writer.print(
            "{c}{c}{c}{c}",
            .{
                table[@as(u8, @intCast(shr(u24, 0b111111_000000_000000_000000 & triad, 18)))],
                table[@as(u8, @intCast(shr(u24, 0b000000_111111_000000_000000 & triad, 12)))],
                if (ok1) table[@as(u8, @intCast(shr(u24, 0b000000_000000_111111_000000 & triad, 6)))] else padding,
                if (ok2) table[@as(u8, @intCast(0b000000_000000_000000_111111 & triad))] else padding,
            },
        );
    }
}

fn decode(buf: []const u8, out: std.fs.File) !void {
    var count: usize = 0;

    while (count < buf.len) : (count += 4) {
        const n0: u24 = if (count < buf.len) buf[count] else 0;
        const n1: u24 = if (count + 1 < buf.len) buf[count + 1] else 0;
        const n2: u24 = if (count + 2 < buf.len) buf[count + 2] else 0;
        const n3: u24 = if (count + 3 < buf.len) buf[count + 3] else 0;

        const shl = std.math.shl;
        const triad: u24 =
            shl(u24, itable[n0], 18) |
            shl(u24, itable[n1], 12) |
            shl(u24, itable[n2], 6) |
            itable[n3];

        const mt: *const [3]u8 = @ptrCast(&@byteSwap(triad));
        _ = try out.write(mt);
    }

    _ = try out.write(&[_]u8{0x0a});
}

fn usage(name: []const u8, w: std.fs.File) void {
    w.writer().print(
        \\{s} [-dvh]
        \\    -d decode
        \\    -v verbose
        \\    -h print help
        \\
        \\{s}
        \\
    , .{ name, version }) catch unreachable;
}

pub fn main() !void {
    const stdout = std.io.getStdOut();
    const stdin = std.io.getStdIn();
    const allocator = std.heap.page_allocator;

    var sess = try Session.fromArgs(stdout, stdin);
    defer sess.deinit();

    if (sess.help) {
        usage(std.mem.span(std.os.argv[0]), stdout);
        return;
    }

    const data = try stdin.reader().readAllAlloc(allocator, 1024 * 1024 * 1024);
    defer allocator.free(data);

    if (sess.decode)
        try decode(data, sess.of)
    else
        try encode(data, sess.of);
}
