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

pub const C = @cImport({
    @cInclude("curl/curl.h");
});

const std = @import("std");

const allocator = std.heap.c_allocator;

const CurlErrors = enum {
    SetOptFail,
    CleanupFail,
};

const buffer = struct {
    len: usize,
    buf: []u8,
};

fn curlToBuffer(data: [*]u8, size: usize, nmbel: usize, dbuf: *buffer) usize {
    const realsize = size * nmbel;
    const prevLen = dbuf.len;

    dbuf.len += realsize;
    dbuf.buf = allocator.realloc(dbuf.buf, dbuf.len) catch |err| {
        std.log.info("memory: {}", .{err});
        return 0;
    };

    std.mem.copy(u8, dbuf.buf[prevLen..], data[0..realsize]);

    return realsize;
}

pub fn get(url: []const u8) ![]u8 {
    var code: C.CURLcode = undefined;
    var client: ?*C.CURL = C.curl_easy_init();

    var dbuf = buffer{
        .len = 0,
        .buf = try allocator.alloc(u8, 0),
    };

    code =
        C.curl_easy_setopt(client, C.CURLOPT_FOLLOWLOCATION, @as(u64, 1)) |
        C.curl_easy_setopt(client, C.CURLOPT_URL, @ptrCast([*c]const u8, url)) |
        C.curl_easy_setopt(client, C.CURLOPT_WRITEFUNCTION, curlToBuffer) |
        C.curl_easy_setopt(client, C.CURLOPT_WRITEDATA, &dbuf) |
        C.curl_easy_perform(client);

    if (code != C.CURLE_OK)
        return error.SetOptFail;

    C.curl_easy_cleanup(client);

    return dbuf.buf[0..];
}
