const std = @import("std");
const Allocator = std.mem.Allocator;

pub const Token = struct {
    data: []const u8,
};

pub const Document = struct {
    pub const Options = struct {
        include_terminator: bool,
    };

    raw: []const u8,
    tokens: std.ArrayList(Token),
    allocator: Allocator,
    options: Options,

    pub fn init(a: Allocator, strdoc: []const u8, options: Options) Document {
        return .{
            .raw = strdoc,
            .tokens = std.ArrayList(Token).init(a),
            .allocator = a,
            .options = options,
        };
    }

    pub fn add(self: *Document, tok: []const u8) !void {
        try self.tokens.append(Token{ .data = tok });
    }

    pub fn deinit(self: *Document) void {
        self.tokens.deinit();
    }
};

/// tokenize will take a string of bytes, and will tokenize all the non
/// whitespace elements.
pub fn tokenize(alloc: Allocator, str: []const u8, options: Document.Options) !Document {
    var doc = Document.init(alloc, str, options);

    var last: usize = 0;
    var curr: usize = 0;
    var wskip = true;

    for (str) |c| {
        switch (c) {
            ' ', '\n', '\r', '\t' => |cc| {
                if (wskip) {
                    curr += 1;
                    last = curr;

                    if (options.include_terminator and cc == '\n')
                        try doc.add("\n");

                    continue;
                }

                try doc.add(str[curr..last]);
                if (options.include_terminator and cc == '\n')
                    try doc.add("\n");

                last += 1;
                curr = last;
                wskip = true;
            },
            else => {
                wskip = false;
                last += 1;
            },
        }
    }

    if (!wskip) try doc.add(str[curr..last]);

    return doc;
}

test "tokenizer test" {
    const ta = std.testing.allocator;
    const tt = std.testing;
    var doc = try tokenize(
        ta,
        \\  the quick brown
        \\ fox jumps
        \\      over the lazy
        \\  dog that is eating
        \\    some other furry animal
    ,
        .{ .include_terminator = false },
    );
    defer doc.deinit();

    inline for ([_][]const u8{
        "the",   "quick", "brown", "fox",
        "jumps", "over",  "the",   "lazy",
        "dog",   "that",  "is",    "eating",
        "some",  "other", "furry", "animal",
    }, doc.tokens.items) |el, its|
        try tt.expectEqualStrings(el, its.data);
}

test "tokenizer with newlines" {
    const ta = std.testing.allocator;
    const tt = std.testing;

    const str = "   why  \n  hello  \n  there  \n  \n";
    var doc = try tokenize(ta, str, .{ .include_terminator = true });
    defer doc.deinit();

    // for (doc.tokens.items) |its|
    //     std.log.warn("item: .{s}.", .{its.data});

    inline for ([_][]const u8{
        "why",   "\n", "hello", "\n",
        "there", "\n", "\n",
    }, doc.tokens.items) |el, its|
        try tt.expectEqualStrings(el, its.data);
}
