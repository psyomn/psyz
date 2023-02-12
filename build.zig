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
const Pkg = std.build.Pkg;

fn mkC(
    name: []const u8,
    path: []const u8,
    b: *std.build.Builder,
    target: *const std.zig.CrossTarget,
    mode: *const std.builtin.Mode,
) *std.build.LibExeObjStep {
    const exe = b.addExecutable(name, path);
    exe.linkLibC();
    exe.setTarget(target.*);
    exe.setBuildMode(mode.*);
    exe.install();
    return exe;
}

const psyds = Pkg{
    .name = "psy-ds",
    .source = .{ .path = "src/ds/ds.zig" },
    .dependencies = null,
};

const misc = Pkg{
    .name = "psy-misc",
    .source = .{ .path = "src/misc/misc.zig" },
    .dependencies = null,
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    {
        const exe = b.addExecutable("psyz", "src/main.zig");
        exe.linkLibC(); // just to run with valgrind
        exe.setTarget(target);
        exe.setBuildMode(mode);
        exe.install();
    }

    {
        const aoc = b.addExecutable("aoc-2022", "src/aoc/2022/main.zig");
        aoc.setTarget(target);
        aoc.setBuildMode(mode);

        aoc.addPackage(psyds);
        aoc.addPackage(misc);

        aoc.linkSystemLibraryName("curl");
        aoc.linkLibC();

        aoc.install();
    }

    {
        const exe = b.addExecutable("dsu", "src/desk/dsu.zig");
        exe.setTarget(target);
        exe.setBuildMode(mode);

        exe.linkLibC();
        exe.linkSystemLibrary("X11");

        exe.install();
    }

    _ = mkC("c_sqrt_example", "src/misc/cstuff/_sqrt.zig", b, &target, &mode);
    _ = mkC("c_str_example", "src/misc/cstuff/_str.zig", b, &target, &mode);
    _ = mkC("c_getopt_example", "src/misc/cstuff/_getopt_example.zig", b, &target, &mode);

    const c_curl = mkC("c_curl_example", "src/misc/cstuff/_curl_example.zig", b, &target, &mode);
    c_curl.linkSystemLibraryName("curl");

    {
        const test_step = b.step("test", "Run unit tests");
        const tests = b.addTest("src/tests.zig");

        tests.setTarget(target);
        tests.setBuildMode(mode);

        test_step.dependOn(&tests.step);
    }
}
