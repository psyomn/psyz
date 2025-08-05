///
/// .SAMXMS... : 1
/// ...S..A... : 0
/// ..A.A.MS.X : 0
/// XMASAMX.MM : 2
/// X.....XA.A : 0
/// S.S.S.S.SS : 0
/// .A.A.A.A.A : 0
/// ..M.M.M.MM : 0
/// .X.X.XMASX : 1
/// 0000001002
///
const std = @import("std");

const Allocator = std.mem.Allocator;

const input = @embedFile("input/4.txt");
const common = @import("common.zig");

fn checkRow(row: []const u8) usize {
    var ret: usize = 0;
    var i: usize = 0;

    while (std.mem.indexOf(u8, row[i..], "XMAS")) |ix| : (i += ix + 1)
        ret += 1;

    i = 0;
    while (std.mem.indexOf(u8, row[i..], "SAMX")) |ix| : (i += ix + 1)
        ret += 1;

    return ret;
}

test checkRow {
    const testing = std.testing;
    try testing.expectEqual(@as(usize, 0), checkRow("nope"));
    try testing.expectEqual(@as(usize, 2), checkRow("nopeXMASAMX"));
    try testing.expectEqual(@as(usize, 1), checkRow("XMAS"));
    try testing.expectEqual(@as(usize, 1), checkRow("XMASXMA"));
    try testing.expectEqual(@as(usize, 2), checkRow("XMASXMAS"));

    try testing.expectEqual(@as(usize, 1), checkRow("SAMX"));
    try testing.expectEqual(@as(usize, 2), checkRow("SAMXSAMX"));
    try testing.expectEqual(@as(usize, 2), checkRow("XMASAMX"));
}

fn checkCol(doc: *const common.Document) usize {
    const nrows = doc.*.tokens.items.len;
    var i: usize = 0;
    var ret: usize = 0;

    var colcount = std.mem.zeroes([1024]u8);

    while (i < nrows - 3) : (i += 1) {
        const ra = doc.*.tokens.items[i];
        const rb = doc.*.tokens.items[i + 1];
        const rc = doc.*.tokens.items[i + 2];
        const rd = doc.*.tokens.items[i + 3];

        std.log.debug("rows {}->{}", .{ i, i + 4 });
        std.log.debug("  {}:{s}", .{ i, ra.data });
        std.log.debug("  {}:{s}", .{ i + 1, rb.data });
        std.log.debug("  {}:{s}", .{ i + 2, rc.data });
        std.log.debug("  {}:{s}", .{ i + 3, rd.data });

        for (ra.data, 0..) |_, ix| {
            if (ra.data[ix] == 'X' and
                rb.data[ix] == 'M' and
                rc.data[ix] == 'A' and
                rd.data[ix] == 'S')
            {
                ret += 1;
                colcount[ix] += 1;
                std.log.debug("    >{}", .{ix});
            }

            if (ra.data[ix] == 'S' and
                rb.data[ix] == 'A' and
                rc.data[ix] == 'M' and
                rd.data[ix] == 'X')
            {
                ret += 1;
                colcount[ix] += 1;

                std.log.debug("    >{}", .{ix});
            }
        }
    }

    // std.log.warn("{any}", .{colcount[0..doc.*.tokens.items.len]});

    return ret;
}

fn checkDiag(doc: *const common.Document) usize {
    const szx = doc.*.tokens.items[0].data.len;
    const szy = doc.*.tokens.items.len;
    var count: usize = 0;

    // X...
    // .M..
    // ..A.
    // ...S <- 3,3

    // X.....X   S.....X
    // .M...M.   .A...M.
    // ..A.A..   ..M.A..
    // ...S...   ...X...
    // ..A.A..   ..A.A..
    // .M...M.   .M...M.
    // X.....X   X.....X

    const ccs = [_][6]i32{
        // [_]i32{ -1, -1, -2, -2, -3, -3 }, // lu
        [_]i32{ -1, 1, -2, 2, -3, 3 }, // ld
        // [_]i32{ 1, 1, 2, 2, 3, 3 }, // ru
        [_]i32{ 1, -1, 2, -2, 3, -3 }, // rd
    };

    for (0..szy) |iy| {
        for (0..szx) |ix| {
            for (ccs) |cr| {
                const six: i32 = @intCast(ix);
                const siy: i32 = @intCast(iy);

                if ((cr[0] + six < 0) or (cr[0] + six >= szx))
                    continue;

                if ((cr[1] + siy < 0) or (cr[1] + siy) >= szy)
                    continue;

                if ((cr[2] + six < 0) or (cr[2] + six) >= szx)
                    continue;

                if ((cr[3] + siy < 0) or (cr[3] + siy) >= szy)
                    continue;

                if ((cr[4] + six < 0) or (cr[4] + six) >= szx)
                    continue;

                if ((cr[5] + siy < 0) or (cr[5] + siy) >= szy)
                    continue;

                const x1: usize = @intCast(cr[0] + six);
                const y1: usize = @intCast(cr[1] + siy);

                const x2: usize = @intCast(cr[2] + six);
                const y2: usize = @intCast(cr[3] + siy);

                const x3: usize = @intCast(cr[4] + six);
                const y3: usize = @intCast(cr[5] + siy);

                const d1 = doc.*.tokens.items[iy].data[ix];
                const d2 = doc.*.tokens.items[y1].data[x1];
                const d3 = doc.*.tokens.items[y2].data[x2];
                const d4 = doc.*.tokens.items[y3].data[x3];

                if (d1 == 'X' and
                    d2 == 'M' and
                    d3 == 'A' and
                    d4 == 'S')
                {
                    // std.log.warn(">> c:{c} x:{} y:{}", .{ d1, ix, iy });
                    count += 1;
                }

                if (d1 == 'S' and
                    d2 == 'A' and
                    d3 == 'M' and
                    d4 == 'X')
                {
                    // std.log.warn(">> x:{} y:{}", .{ ix, iy });
                    count += 1;
                }
            }
        }
    }

    return count;
}

fn calculate(doc: *const common.Document) usize {
    var rowcnt: usize = 0;
    var colcnt: usize = 0;
    var diacnt: usize = 0;

    for (doc.*.tokens.items) |row| {
        const cnt = checkRow(row.data);
        // std.log.warn("{s} : {}", .{ row.data, cnt });
        rowcnt += cnt;
    }

    colcnt = checkCol(doc);

    diacnt = checkDiag(doc);

    // std.log.warn("rows{} cols{} diag{}", .{ rowcnt, colcnt, diacnt });

    return rowcnt + colcnt + diacnt;
}

fn calculate2(doc: *const common.Document) usize {
    const szx = doc.*.tokens.items[0].data.len;
    const szy = doc.*.tokens.items.len;
    var count: usize = 0;

    const rows = doc.*.tokens.items;

    for (0..szy) |iy| {
        for (0..szx) |ix| {
            if (rows[iy].data[ix] != 'X') continue;

            if (ix + 3 < szx and std.mem.eql(u8, rows[iy].data[ix .. ix + 4], "XMAS"))
                count += 1;

            if (ix >= 3 and std.mem.eql(u8, rows[iy].data[ix - 3 .. ix + 1], "SAMX"))
                count += 1;

            if (iy + 3 < szy)
                count += if (rows[iy + 1].data[ix] == 'M' and rows[iy + 2].data[ix] == 'A' and rows[iy + 3].data[ix] == 'S') 1 else 0;

            if (iy >= 3)
                count += if (rows[iy - 1].data[ix] == 'M' and rows[iy - 2].data[ix] == 'A' and rows[iy - 3].data[ix] == 'S') 1 else 0;

            // dlu -1 -1,
            if ((iy >= 3) and (ix >= 3))
                count += if (rows[iy - 1].data[ix - 1] == 'M' and
                    rows[iy - 2].data[ix - 2] == 'A' and
                    rows[iy - 3].data[ix - 3] == 'S') 1 else 0;
            // dru
            if ((iy >= 3) and (ix + 3 < szx))
                count += if (rows[iy - 1].data[ix + 1] == 'M' and
                    rows[iy - 2].data[ix + 2] == 'A' and
                    rows[iy - 3].data[ix + 3] == 'S') 1 else 0;

            // dld
            if ((iy + 3 < szy) and (ix >= 3))
                count += if (rows[iy + 1].data[ix - 1] == 'M' and
                    rows[iy + 2].data[ix - 2] == 'A' and
                    rows[iy + 3].data[ix - 3] == 'S') 1 else 0;

            // drd
            if ((iy + 3 < szy) and (ix + 3 < szx))
                count += if (rows[iy + 1].data[ix + 1] == 'M' and
                    rows[iy + 2].data[ix + 2] == 'A' and
                    rows[iy + 3].data[ix + 3] == 'S') 1 else 0;
        }
    }

    return count;
}

fn calculate3(doc: *const common.Document) usize {
    // make a arraylist and append the matches for each index starting at A
    // if index count == 2, result++

    const szx = doc.*.tokens.items[0].data.len;
    const szy = doc.*.tokens.items.len;
    var inner: usize = 0;
    var count: usize = 0;

    const rows = doc.*.tokens.items;

    for (0..szy) |iy| {
        for (0..szx) |ix| {
            if (rows[iy].data[ix] != 'A') continue;

            inner = 0;
            // M S | M M | S M | S S
            //  A  |  A  |  A  |  A
            // M S | S S | S M | M M

            // dlu -1 -1,
            if ((iy >= 1) and (ix >= 1) and (ix + 1 < szx) and (iy + 1 < szy)) {
                // M
                //  A
                //   S
                inner +=
                    if (rows[iy - 1].data[ix - 1] == 'M' and
                    rows[iy + 1].data[ix + 1] == 'S') 1 else 0;

                //   S
                //  A
                // M
                inner +=
                    if (rows[iy + 1].data[ix - 1] == 'M' and
                    rows[iy - 1].data[ix + 1] == 'S') 1 else 0;

                //   M
                //  A
                // S
                inner +=
                    if (rows[iy - 1].data[ix + 1] == 'M' and
                    rows[iy + 1].data[ix - 1] == 'S') 1 else 0;

                // S
                //  A
                //   M
                inner +=
                    if (rows[iy + 1].data[ix + 1] == 'M' and
                    rows[iy - 1].data[ix - 1] == 'S') 1 else 0;
            }

            if (inner == 2) {
                // std.log.debug("inner: \n\t{s}\n\t{s}\n\t{s}", .{
                //     rows[iy - 1].data[ix - 1 .. ix + 2],
                //     rows[iy].data[ix - 1 .. ix + 2],
                //     rows[iy + 1].data[ix - 1 .. ix + 2],
                // });
                count += 1;
            }
        }
    }

    return count;
}

test calculate3 {
    {
        const tc =
            \\.....
            \\.S.M.
            \\..A..
            \\.S.M.
            \\.....
        ;

        // [default] (warn): incr, index y:1, x2
        // [default] (warn): incr, index y:2, x6  v
        // [default] (warn): incr, index y:2, x7  v
        // [default] (warn): incr, index y:3, x2
        //
        // y3 x4
        //   S.M
        //   .AS
        //   S.M
        //
        // [default] (warn): incr, index y:7, x1  v
        // [default] (warn): incr, index y:7, x3  v
        // [default] (warn): incr, index y:7, x5  v
        // [default] (warn): incr, index y:7, x7  v

        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();

        try std.testing.expectEqual(@as(usize, 1), calculate3(&doc));
    }

    {
        const tc =
            \\.M.S......
            \\..A..MSMS.
            \\.M.S.MAA..
            \\..A.ASMSM.
            \\.M.S.M....
            \\..........
            \\S.S.S.S.S.
            \\.A.A.A.A..
            \\M.M.M.M.M.
            \\..........
        ;

        // [default] (warn): incr, index y:1, x2
        // [default] (warn): incr, index y:2, x6  v
        // [default] (warn): incr, index y:2, x7  v
        // [default] (warn): incr, index y:3, x2
        //
        // y3 x4
        //   S.M
        //   .AS
        //   S.M
        //
        // [default] (warn): incr, index y:7, x1  v
        // [default] (warn): incr, index y:7, x3  v
        // [default] (warn): incr, index y:7, x5  v
        // [default] (warn): incr, index y:7, x7  v

        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();

        try std.testing.expectEqual(@as(usize, 9), calculate3(&doc));
    }
}

test calculate {
    std.log.warn("", .{});

    {
        const tc =
            \\....XXMAS.
            \\.SAMXMS...
            \\...S..A...
            \\..A.A.MS.X
            \\XMASAMX.MM
            \\X.....XA.A
            \\S.S.S.S.SS
            \\.A.A.A.A.A
            \\..M.M.M.MM
            \\.X.X.XMASX
        ;

        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();

        try std.testing.expectEqual(@as(usize, 18), calculate(&doc));
    }
}
test calculate2 {
    {
        var doc = try common.tokenize(std.testing.allocator, "XMAS\n", .{ .include_terminator = false });
        defer doc.deinit();
        try std.testing.expectEqual(@as(usize, 1), calculate2(&doc));
    }

    {
        var doc = try common.tokenize(std.testing.allocator, "SAMX\n", .{ .include_terminator = false });
        defer doc.deinit();
        try std.testing.expectEqual(@as(usize, 1), calculate2(&doc));
    }

    {
        var doc = try common.tokenize(std.testing.allocator, "XMASAMX\n", .{ .include_terminator = false });
        defer doc.deinit();
        try std.testing.expectEqual(@as(usize, 2), calculate2(&doc));
    }

    {
        const tc =
            \\X......
            \\M......
            \\A......
            \\S..X..S
            \\...M..A
            \\...A..M
            \\...S..X
        ;
        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();
        try std.testing.expectEqual(@as(usize, 3), calculate2(&doc));
    }

    {
        const tc =
            \\X..X..X
            \\.M.M.M.
            \\..AAA..
            \\...S...
            \\..A.A..
            \\XMAS.M.
            \\X.....X
        ;

        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();
        try std.testing.expectEqual(@as(usize, 6), calculate2(&doc));
    }

    {
        const tc =
            \\....XXMAS.
            \\.SAMXMS...
            \\...S..A...
            \\..A.A.MS.X
            \\XMASAMX.MM
            \\X.....XA.A
            \\S.S.S.S.SS
            \\.A.A.A.A.A
            \\..M.M.M.MM
            \\.X.X.XMASX
        ;

        var doc = try common.tokenize(std.testing.allocator, tc, .{ .include_terminator = false });
        defer doc.deinit();

        try std.testing.expectEqual(@as(usize, 18), calculate2(&doc));
    }
}

pub fn run() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    defer if (gpa.deinit() == .leak) @panic("leaks will drown us all");

    var doc = common.tokenize(alloc, input, .{ .include_terminator = false }) catch @panic("cannot tokenize");
    defer doc.deinit();

    std.log.debug("part 1c2: {d}", .{calculate2(&doc)});
    std.log.debug("part 2c3: {d}", .{calculate3(&doc)});
}
