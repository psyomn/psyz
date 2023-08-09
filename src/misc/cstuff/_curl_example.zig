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

const curl = @import("c_curl.zig");
const getopt = @import("c_getopt.zig");

const allocator = std.heap.c_allocator;

const Session = struct {
    url: ?[]u8,

    pub fn destroy(self: Session) void {
        if (self.url) |url| {
            allocator.free(url);
        }
    }
};

const DefaultUrl = "http://www.isitfridayyet.net";

pub fn main() !void {
    var sess = Session{
        .url = null,
    };

    {
        var ret = getopt.getopt(std.os.argv, "u:");
        while (ret != -1) : (ret = getopt.getopt(std.os.argv, "u:")) {
            switch (ret) {
                'u' => {
                    // TODO: need to free this
                    var optbuf = allocator.alloc(u8, getopt.optargLen()) catch |err| {
                        std.log.err("{}", .{err});
                        @panic("coud not allocate optarg buf");
                    };
                    std.mem.copy(u8, optbuf[0..], getopt.optargAsSlice()[0..]);
                    sess.url = optbuf;
                },
                '?' => std.log.info("usage:  zurl [-u your url]", .{}),
                else => unreachable,
            }
        }
    }

    const usebuf: []const u8 = if (sess.url) |v| v else DefaultUrl[0..DefaultUrl.len];

    std.log.info("looking up: {s}", .{usebuf});
    const ret = curl.get(usebuf[0..]) catch |err| {
        std.log.info("error {}", .{err});
        return err;
    };

    defer allocator.free(ret);

    std.log.info("{s}", .{ret[0..ret.len]});
    std.log.info("bytes: {d}", .{ret.len});
}
