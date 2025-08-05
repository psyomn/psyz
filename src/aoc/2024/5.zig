const std = @import("std");

const Allocator = std.mem.Allocator;

const common = @import("common.zig");

pub fn run() void {}

fn calculate(doc: *const common.Document) usize {
    _ = doc;
    return 0;
}

const d5 = struct {
    entries: common.Document = undefined,
    checks: common.Document = undefined,

    pub fn deinit(self: *d5) void {
        self.entries.deinit();
        self.checks.deinit();
    }

    pub fn makeEntryList(self: d5, a: Allocator) !std.ArrayList([2]i32) {
        var ar = std.ArrayList([2]i32).init(a);

        for (self.entries.tokens.items) |tok| {
            var it = std.mem.split(u8, tok.data, "|");
            const ea = try std.fmt.parseInt(i32, it.next().?, 0);
            const eb = try std.fmt.parseInt(i32, it.next().?, 0);
            try ar.append(.{ ea, eb });
        }

        return ar;
    }

    pub fn makeChecksList(self: d5, a: Allocator) !std.ArrayList(i32) {
        var ar = std.ArrayList(i32).init(a);

        for (self.checks.tokens.items) |tok| {
            var it = std.mem.split(u8, tok.data, ",");
            while (it.next()) |nx|
                try ar.append(try std.fmt.parseInt(i32, nx, 0));
        }

        return ar;
    }
};

fn parseDocuments(
    a: Allocator,
    text: []const u8,
) !d5 {
    var it = std.mem.split(u8, text, "\n\n");
    var rd5 = d5{};

    if (it.next()) |ents|
        rd5.entries = try common.tokenize(a, ents, .{ .include_terminator = false })
    else
        return error.MissingEntries;

    if (it.next()) |chks|
        rd5.checks = try common.tokenize(a, chks, .{ .include_terminator = false })
    else
        return error.MissingChecks;

    return rd5;
}

const Pos = enum {
    left,
    right,
};

fn findXmost(arr: std.ArrayList([2]i32), pos: Pos) ?i32 {
    const aix: usize = if (pos == .left) 0 else 1;
    const bix: usize = if (pos == .left) 1 else 0;

    for (arr.items) |a| {
        var found = false;

        for (arr.items) |b| {
            found = found or a[aix] == b[bix];
            if (found) break;
        }

        if (!found) {
            return a[aix];
        }
    }

    return null;
}

test calculate {
    const tc =
        \\47|53
        \\97|13
        \\97|61
        \\97|47
        \\75|29
        \\61|13
        \\75|53
        \\29|13
        \\97|29
        \\53|29
        \\61|53
        \\97|53
        \\61|29
        \\47|13
        \\75|47
        \\97|75
        \\47|61
        \\75|61
        \\47|29
        \\75|13
        \\53|13
        \\
        \\75,47,61,53,29
        \\97,61,53,29,13
        \\75,29,13
        \\75,97,47,61,53
        \\61,13,29
        \\97,13,75,29,47
    ;

    var rd5 = parseDocuments(std.testing.allocator, tc) catch |err| {
        std.log.err("parse documents {}", .{err});
        @panic("problem parsing documents");
    };

    defer rd5.deinit();

    std.log.warn("==entries ===", .{});
    for (rd5.entries.tokens.items) |it| std.log.warn("- {s}", .{it.data});

    std.log.warn("==checks ===", .{});
    for (rd5.checks.tokens.items) |it| std.log.warn("- {s}", .{it.data});

    var el = try rd5.makeEntryList(std.testing.allocator);
    defer el.deinit();
    std.log.warn("entries {any}", .{el.items});

    var cl = try rd5.makeChecksList(std.testing.allocator);
    defer cl.deinit();
    std.log.warn("checks {any}", .{cl.items});

    const leftmost = findXmost(el, .left).?;
    const rightmost = findXmost(el, .right).?;
    std.log.warn("{any} {any}", .{ leftmost, rightmost });

    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit();

    try list.append(leftmost);
    try list.append(rightmost);

    for (el.items) |it| {
        const a = it[0];
        const b = it[1];
        const aix = std.mem.indexOfScalar(i32, list.items, a);
        const bix = std.mem.indexOfScalar(i32, list.items, b);

        if (aix and bix) continue;

        if (aix and !bix) {
            try list.insert(aix, b);
        }

        if (aix) if (bix) |bb|
            try list.insert(bb - 1, a);

        if (!aix and !bix) {
            try list.insert(1, b);
            try list.insert(1, a);
        }
    }
}
