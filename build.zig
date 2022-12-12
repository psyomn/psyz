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
    .path = .{ .path = "src/ds/ds.zig" },
    .dependencies = null,
};

const misc = Pkg{
    .name = "psy-misc",
    .path = .{ .path = "src/misc/misc.zig" },
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

        const run_cmd = exe.run();
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }

        const run_step = b.step("run", "Run the app");
        run_step.dependOn(&run_cmd.step);
    }

    {
        const aoc = b.addExecutable("aoc-2022", "src/aoc/2022/main.zig");
        aoc.setTarget(target);
        aoc.setBuildMode(mode);

        aoc.addPackage(psyds);
        aoc.addPackage(misc);
        aoc.linkLibC();

        aoc.install();
    }

    _ = mkC("c_sqrt_example", "src/misc/cstuff/_sqrt.zig", b, &target, &mode);
    _ = mkC("c_str_example", "src/misc/cstuff/_str.zig", b, &target, &mode);
    _ = mkC("c_getopt_example", "src/misc/cstuff/_getopt_example.zig", b, &target, &mode);

    const c_curl = mkC("c_curl_example", "src/misc/cstuff/_curl_example.zig", b, &target, &mode);
    c_curl.addIncludeDir("/usr/include/");
    c_curl.linkSystemLibraryName("curl");

    {
        const test_step = b.step("test", "Run unit tests");
        const tests = b.addTest("src/tests.zig");

        tests.setTarget(target);
        tests.setBuildMode(mode);

        test_step.dependOn(&tests.step);
    }
}
