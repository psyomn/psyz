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
const Mod = std.build.Module;

fn mkC(
    name: []const u8,
    path: []const u8,
    b: *std.build.Builder,
    target: std.zig.CrossTarget,
    optimize: std.builtin.OptimizeMode,
) *std.build.LibExeObjStep {
    const exe = b.addExecutable(.{
        .name = name,
        .root_source_file = .{ .path = path },
        .target = target,
        .optimize = optimize,
    });
    exe.linkLibC();
    b.installArtifact(exe);
    return exe;
}

pub fn build(b: *std.build.Builder) void {
    const psyds = b.createModule(.{
        .source_file = .{ .path = "src/ds/ds.zig" },
    });

    const misc = b.createModule(.{
        .source_file = .{ .path = "src/misc/misc.zig" },
    });

    const utils = b.createModule(.{
        .source_file = .{ .path = "src/utils/version.zig" },
    });

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    blk: {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer if (gpa.deinit() == .ok) std.log.warn("leaks detected in version tag generation", .{});

        const cmdline = [_][]const u8{ "git", "describe", "--dirty", "--tags", "--abbrev=0" };
        const result = std.ChildProcess.exec(.{
            .allocator = allocator,
            .argv = cmdline[0..],
        }) catch |err| {
            std.log.err("error running command: {any} -- version will not be updated", .{err});
            break :blk;
        };
        defer {
            allocator.free(result.stdout);
            allocator.free(result.stderr);
        }

        const versionStr = std.mem.trim(u8, result.stdout[0..], "\n");
        const versionPath = "src/utils/version.txt";
        std.log.info("overwriting tagfile {s} with {s}", .{ versionPath, versionStr });

        var fh = std.fs.cwd().openFile(versionPath, .{ .mode = .read_write }) catch |err| {
            std.log.err("could not open version file {any}", .{err});
            break :blk;
        };
        defer fh.close();

        fh.writeAll(versionStr) catch |err| {
            std.log.err("could not write git tag to version file: {any}", .{err});
            break :blk;
        };
    }

    {
        const exe = b.addExecutable(.{
            .name = "psyz",
            .root_source_file = .{ .path = "src/main.zig" },
            .target = target,
            .optimize = optimize,
        });

        exe.linkLibC(); // just to run with valgrind
        b.installArtifact(exe);
    }

    {
        const aoc = b.addExecutable(.{
            .name = "aoc-2022",
            .root_source_file = .{ .path = "src/aoc/2022/main.zig" },
            .target = target,
            .optimize = optimize,
        });
        aoc.addModule("psy-ds", psyds);
        aoc.addModule("psy-misc", misc);

        aoc.linkSystemLibraryName("curl");
        aoc.linkLibC();

        b.installArtifact(aoc);
    }

    {
        const exe = b.addExecutable(.{
            .name = "dsu",
            .root_source_file = .{ .path = "src/desk/dsu.zig" },
            .target = target,
            .optimize = optimize,
        });
        exe.addModule("psy-utils", utils);

        exe.linkLibC();
        exe.linkSystemLibrary("X11");

        b.installArtifact(exe);
    }

    _ = mkC("c_sqrt_example", "src/misc/cstuff/_sqrt.zig", b, target, optimize);
    _ = mkC("c_str_example", "src/misc/cstuff/_str.zig", b, target, optimize);
    _ = mkC("c_getopt_example", "src/misc/cstuff/_getopt_example.zig", b, target, optimize);

    const c_curl = mkC("c_curl_example", "src/misc/cstuff/_curl_example.zig", b, target, optimize);
    c_curl.linkSystemLibraryName("curl");

    {
        const tests = b.addTest(.{
            .root_source_file = .{ .path = "src/tests.zig" },
            .target = target,
            .optimize = optimize,
        });

        const run_unit_tests = b.addRunArtifact(tests);

        const test_step = b.step("test", "Run unit tests");
        test_step.dependOn(&run_unit_tests.step);
    }
}
