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
const os = std.os;

const getopt = @import("./c_getopt.zig");

const sessionBufSz: usize = 514;

const Session = struct {
    version: bool,
    opt_a: bool,
    opt_b: bool,
    opt_c: bool,
    opt_d: [sessionBufSz]u8,

    pub fn init() Session {
        return Session{
            .version = false,
            .opt_a = false,
            .opt_b = false,
            .opt_c = false,
            .opt_d = [_]u8{0} ** sessionBufSz,
        };
    }
};

pub fn main() !void {
    var sess = Session.init();

    var ret = getopt.getopt(os.argv, "vabcd:");
    while (ret != -1) : (ret = getopt.getopt(os.argv, "vabcd:")) {
        switch (@intCast(u8, ret)) {
            'a' => sess.opt_a = true,
            'b' => sess.opt_b = true,
            'c' => sess.opt_c = true,
            'd' => std.mem.copy(u8, sess.opt_d[0..], getopt.optargAsSlice()[0..]),
            'v' => sess.version = true,
            '?' => {
                std.log.info("bad parameters.  try --help", .{});
                return getopt.GetoptError.BadOpt;
            },
            else => std.log.info("herp", .{}),
        }
    }

    std.log.info("{}", .{sess});
}
