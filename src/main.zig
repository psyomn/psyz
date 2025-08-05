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

const translation_hi = [_]u8{
    'a', 'e',
    'i', 'o',
    'p', 'b',
    'c', 'd',
    'f', 'g',
    'h', 'j',
    'k', 'l',
    'm', 'n',

    // will not reach
    'q', 'r',
    's', 't',
    'u', 'v',
    'w', 'x',
    'y', 'z',
};

const translation_lo = [_]u8{
    'c', 'd', 'f', 'g',
    'h', 'j', 'k', 'l',
    'm', 'n', 'p',

    // will not reach
    'q',
    'r', 's', 't', 'u',
    'v', 'w', 'x', 'y',
    'z', 'a', 'b', 'e',
    'i', 'o',
};

pub fn encodeOctet(val: u8) [2]u8 {
    const hi: u8 = @intCast(@shrExact(val & 0xf0, 4));
    const lo: u8 = @intCast(val & 0x0f);
    return .{ translation_hi[hi], translation_lo[lo] };
}

pub fn encodeAddress(addr: *const std.net.Address, buf: []u8) !void {
    const bytes = @as(*const [4]u8, @ptrCast(&addr.in.sa.addr));

    var sz: usize = 0;
    for (bytes) |byt| {
        const a = encodeOctet(byt);
        @memcpy(buf[sz..], &a);
        sz += a.len;
    }
}

const ConvAddr = struct {
    addr: std.net.Address,
    convert: [8]u8,
    country: []const u8,
};

pub fn main() !void {
    const stdin = std.io.getStdIn().reader();
    var buf = std.io.bufferedReader(stdin);
    var r = buf.reader();

    const stdout = std.io.getStdOut().writer();
    var obuf = std.io.bufferedWriter(stdout);
    var out = obuf.writer();

    var input: [4096]u8 = undefined;
    while (try r.readUntilDelimiterOrEof(&input, '\n')) |line| {
        var iit = std.mem.splitScalar(u8, line, ',');

        var addr_from = std.net.Address.parseIp(iit.next().?, 0) catch |err| {
            std.log.err("could not parse ip: {}, {s}", .{ err, line });
            continue;
        };

        const addr_to = std.net.Address.parseIp(iit.next().?, 0) catch |err| {
            std.log.err("could not parse ip: {}, {s}", .{ err, line });
            continue;
        };
        _ = addr_to;

        const country = iit.next().?;

        var pretty_buf: [8]u8 = undefined;
        try encodeAddress(&addr_from, &pretty_buf);

        try out.print(
            "{}({s}) -> {s}\n",
            .{ addr_from, country, pretty_buf },
        );
    }

    try obuf.flush();
}
