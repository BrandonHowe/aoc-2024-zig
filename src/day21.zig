const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day21.txt");
const stdout = std.io.getStdOut().writer();

const Vec = struct
{
    x: i8,
    y: i8,
    pressCount: i8,
};

pub fn printListVec(vecs: []Vec) !void
{
    for (vecs) |vec|
    {
        if (vec.x < 0)
        {
            for (0..@as(usize, @intCast(-vec.x))) |_| try stdout.print("<", .{});
        }
        if (vec.y < 0)
        {
            for (0..@as(usize, @intCast(-vec.y))) |_| try stdout.print("v", .{});
        }
        if (vec.y > 0)
        {
            for (0..@as(usize, @intCast(vec.y))) |_| try stdout.print("^", .{});
        }
        if (vec.x > 0)
        {
            for (0..@as(usize, @intCast(vec.x))) |_| try stdout.print(">", .{});
        }
        for (0..@as(usize, @intCast(vec.pressCount))) |_| try stdout.print("A", .{});
        try stdout.print(" ", .{});
    }
    try stdout.print("\n", .{});
}

pub fn findOrdersForNumericKeypad(code: []const u8) ![]Vec
{
    var entries = List(Vec).init(gpa);

    var pos = Vec{ .x = 2, .y = 0, .pressCount = 0 };
    for (code) |char|
    {
        const targetPos = switch (char) {
            'A' => Vec{ .x = 2, .y = 0, .pressCount = 1 },
            '0' => Vec{ .x = 1, .y = 0, .pressCount = 1 },
            '1' => Vec{ .x = 0, .y = 1, .pressCount = 1 },
            '2' => Vec{ .x = 1, .y = 1, .pressCount = 1 },
            '3' => Vec{ .x = 2, .y = 1, .pressCount = 1 },
            '4' => Vec{ .x = 0, .y = 2, .pressCount = 1 },
            '5' => Vec{ .x = 1, .y = 2, .pressCount = 1 },
            '6' => Vec{ .x = 2, .y = 2, .pressCount = 1 },
            '7' => Vec{ .x = 0, .y = 3, .pressCount = 1 },
            '8' => Vec{ .x = 1, .y = 3, .pressCount = 1 },
            '9' => Vec{ .x = 2, .y = 3, .pressCount = 1 },
            else => Vec{ .x = 0, .y = 0, .pressCount = 0 }
        };
        const diff = Vec{ .x = targetPos.x - pos.x, .y = targetPos.y - pos.y, .pressCount = 1 };
        try entries.append(diff);
        pos = targetPos;
    }

    return entries.toOwnedSlice();
}

pub fn findJoystickOrdersForNumeric(numericDirs: []Vec, numPad: bool, allocator: Allocator) ![]Vec
{
    var entries = List(Vec).init(allocator);

    const blankPosition: i8 = if (numPad) 0 else 1;
    var absolutePos = Vec{ .x = 2, .y = blankPosition, .pressCount = 0 };
    for (numericDirs) |numericDir|
    {
        var pos = Vec{ .x = 2, .y = 1, .pressCount = 0 };
        const goesOverGapLeft = (absolutePos.x + numericDir.x == 0 and absolutePos.y == blankPosition);
        const goesOverGapRight = (absolutePos.x == 0 and absolutePos.y + numericDir.y == blankPosition);
        if (numericDir.x < 0 and !goesOverGapLeft)
        {
            try entries.append(Vec{ .x = 0 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.x });
            pos = Vec{ .x = 0, .y = 0, .pressCount = 0 };
        }
        if (numericDir.x > 0 and goesOverGapRight)
        {
            try entries.append(Vec{ .x = 2 - pos.x, .y = 0 - pos.y, .pressCount = numericDir.x });
            pos = Vec{ .x = 2, .y = 0, .pressCount = 0 };
        }
        if (numericDir.y < 0)
        {
            try entries.append(Vec{ .x = 1 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.y });
            pos = Vec{ .x = 1, .y = 0, .pressCount = 0 };
        }
        if (numericDir.y > 0)
        {
            try entries.append(Vec{ .x = 1 - pos.x, .y = 1 - pos.y, .pressCount = numericDir.y });
            pos = Vec{ .x = 1, .y = 1, .pressCount = 0 };
        }
        if (numericDir.x < 0 and goesOverGapLeft)
        {
            try entries.append(Vec{ .x = 0 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.x });
            pos = Vec{ .x = 0, .y = 0, .pressCount = 0 };
        }
        if (numericDir.x > 0 and !goesOverGapRight)
        {
            try entries.append(Vec{ .x = 2 - pos.x, .y = 0 - pos.y, .pressCount = numericDir.x });
            pos = Vec{ .x = 2, .y = 0, .pressCount = 0 };
        }
        absolutePos.x += numericDir.x;
        absolutePos.y += numericDir.y;
        try entries.append(Vec{ .x = 2 - pos.x, .y = 1 - pos.y, .pressCount = numericDir.pressCount });
    }

    return entries.toOwnedSlice();
}

pub fn getLengthOfJoystickOrders(orders: []Vec) i32
{
    var total: i32 = 0;
    for (orders) |order|
    {
        const absX = if (order.x < 0) -order.x else order.x;
        const absY = if (order.y < 0) -order.y else order.y;
        total += absX + absY + order.pressCount;
    }
    return total;
}

pub fn part1(codes: [][]const u8) !void
{
    var total: i32 = 0;
    for (codes) |code|
    {
        const numericOrders = try findOrdersForNumericKeypad(code);
        const joystickOrders1 = try findJoystickOrdersForNumeric(numericOrders, true, gpa);
        const playerOrders = try findJoystickOrdersForNumeric(joystickOrders1, false, gpa);
        defer gpa.free(numericOrders);
        defer gpa.free(joystickOrders1);
        defer gpa.free(playerOrders);

        const intStr = code[0..(code.len - 1)];
        const int = try parseInt(i16, intStr, 10);
        total += getLengthOfJoystickOrders(playerOrders) * int;
    }
    try stdout.print("Part 1: {}\n", .{total});
}

const CacheItem = struct
{
    pos: Vec,
    dir: Vec,
    levelsLeft: u8
};

var cache = Map(CacheItem, i128).init(gpa);

pub fn findJoystickLengthForNumeric(numericDirs: []Vec, levelsLeft: u8, allocator: Allocator) !i128
{
    if (levelsLeft == 0) return getLengthOfJoystickOrders(numericDirs);

    var entries = List(Vec).init(allocator);

    var sum: i128 = 0;
    var absolutePos = Vec{ .x = 2, .y = 1, .pressCount = 0 };
    for (numericDirs) |numericDir|
    {
        entries.clearRetainingCapacity();

        const cacheItem = CacheItem{ .pos = absolutePos, .dir = numericDir, .levelsLeft = levelsLeft };
        if (cache.get(cacheItem)) |val|
        {
            sum += val;
            absolutePos.x += numericDir.x;
            absolutePos.y += numericDir.y;
            continue;
        }

        var pos = Vec{ .x = 2, .y = 1, .pressCount = 0 };
        const goesOverGapLeft = (absolutePos.x + numericDir.x == 0 and absolutePos.y == 1);
        const goesOverGapRight = (absolutePos.x == 0 and absolutePos.y + numericDir.y == 1);
        if (numericDir.x < 0 and !goesOverGapLeft)
        {
            try entries.append(Vec{ .x = 0 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.x });
            pos = Vec{ .x = 0, .y = 0, .pressCount = 0 };
        }
        if (numericDir.x > 0 and goesOverGapRight)
        {
            try entries.append(Vec{ .x = 2 - pos.x, .y = 0 - pos.y, .pressCount = numericDir.x });
            pos = Vec{ .x = 2, .y = 0, .pressCount = 0 };
        }
        if (numericDir.y < 0)
        {
            try entries.append(Vec{ .x = 1 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.y });
            pos = Vec{ .x = 1, .y = 0, .pressCount = 0 };
        }
        if (numericDir.y > 0)
        {
            try entries.append(Vec{ .x = 1 - pos.x, .y = 1 - pos.y, .pressCount = numericDir.y });
            pos = Vec{ .x = 1, .y = 1, .pressCount = 0 };
        }
        if (numericDir.x < 0 and goesOverGapLeft)
        {
            try entries.append(Vec{ .x = 0 - pos.x, .y = 0 - pos.y, .pressCount = -numericDir.x });
            pos = Vec{ .x = 0, .y = 0, .pressCount = 0 };
        }
        if (numericDir.x > 0 and !goesOverGapRight)
        {
            try entries.append(Vec{ .x = 2 - pos.x, .y = 0 - pos.y, .pressCount = numericDir.x });
            pos = Vec{ .x = 2, .y = 0, .pressCount = 0 };
        }
        absolutePos.x += numericDir.x;
        absolutePos.y += numericDir.y;
        try entries.append(Vec{ .x = 2 - pos.x, .y = 1 - pos.y, .pressCount = numericDir.pressCount });

        const total = try findJoystickLengthForNumeric(entries.items, levelsLeft - 1, allocator);
        sum += total;
        try cache.put(cacheItem, total);
    }

    return sum;
}

pub fn part2(codes: [][]const u8) !void
{
    var total: i128 = 0;
    for (codes) |code|
    {
        var arena = std.heap.ArenaAllocator.init(gpa);
        defer arena.deinit();
        const allocator = arena.allocator();

        const intStr = code[0..(code.len - 1)];
        const int = try parseInt(i128, intStr, 10);

        var orders = try findOrdersForNumericKeypad(code);
        orders = try findJoystickOrdersForNumeric(orders, true, allocator);
        const levels = 24;
        const length1 = try findJoystickLengthForNumeric(orders, levels, allocator);
        defer allocator.free(orders);
        total += length1 * int;
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const codes = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(codes);
    const t1 = std.time.milliTimestamp();
    try part1(codes);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(codes);
    const t3 = std.time.milliTimestamp();
    try stdout.print("Part 2: {}ms\n", .{t3 - t2});
}

// Useful stdlib functions
const tokenizeAny = std.mem.tokenizeAny;
const tokenizeSeq = std.mem.tokenizeSequence;
const tokenizeSca = std.mem.tokenizeScalar;
const splitAny = std.mem.splitAny;
const splitSeq = std.mem.splitSequence;
const splitSca = std.mem.splitScalar;
const indexOf = std.mem.indexOfScalar;
const indexOfAny = std.mem.indexOfAny;
const indexOfStr = std.mem.indexOfPosLinear;
const lastIndexOf = std.mem.lastIndexOfScalar;
const lastIndexOfAny = std.mem.lastIndexOfAny;
const lastIndexOfStr = std.mem.lastIndexOfLinear;
const trim = std.mem.trim;
const sliceMin = std.mem.min;
const sliceMax = std.mem.max;

const parseInt = std.fmt.parseInt;
const parseFloat = std.fmt.parseFloat;

const print = std.debug.print;
const assert = std.debug.assert;

const sort = std.sort.block;
const asc = std.sort.asc;
const desc = std.sort.desc;

// Generated from template/template.zig.
// Run `zig build generate` to update.
// Only unmodified days will be updated.
