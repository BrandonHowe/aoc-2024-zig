const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day25.txt");
const stdout = std.io.getStdOut().writer();

const Pattern = struct
{
    isLock: bool,
    pattern: [5]i8
};

pub fn part1() !void
{
    const buffer = try gpa.alloc(u8, 10000);
    defer gpa.free(buffer);
    var fba = std.heap.FixedBufferAllocator.init(buffer);
    const allocator = fba.allocator();

    var locks = List(Pattern).init(gpa);
    defer locks.clearAndFree();
    var keys = List(Pattern).init(gpa);
    defer keys.clearAndFree();

    var it = splitSeq(u8, data, "\n\n");
    while (it.next()) |str|
    {
        const lines = try util.splitInputIntoLines(str, allocator);
        const isLock = lines[0][0] == '#';
        var pattern = [5]i8{ 0, 0, 0, 0, 0 };
        for (0..5) |x|
        {
            var fillCount: i8 = -1;
            for (0..lines.len) |y|
            {
                if (lines[y][x] == '#') fillCount += 1;
            }
            pattern[x] = fillCount;
        }
        if (isLock)
        {
            try locks.append(Pattern{ .isLock = isLock, .pattern = pattern });
        }
        else
        {
            try keys.append(Pattern{ .isLock = isLock, .pattern = pattern });
        }

        fba.reset();
    }
    var successfulPairings: u32 = 0;
    for (locks.items) |lock|
    {
        keyIt: for (keys.items) |key|
        {
            for (0..lock.pattern.len) |i|
            {
                if (lock.pattern[i] + key.pattern[i] > 5) continue :keyIt;
            }
            successfulPairings += 1;
        }
    }
    try stdout.print("Part 1: {}\n", .{successfulPairings});
}

pub fn part2() !void
{
    try stdout.print("Part 2: Merry Christmas!\n", .{});
}

pub fn main() !void
{
    const t1 = std.time.milliTimestamp();
    try part1();
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2();
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
