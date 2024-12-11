const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day11.txt");
const stdout = std.io.getStdOut().writer();

pub fn solve(iters: u8) !u64
{
    var map = Map(u64, u64).init(gpa);
    defer map.deinit();

    {
        var it = splitSca(u8, data, ' ');
        while (it.next()) |item| {
            const parsed = try parseInt(u64, item, 10);
            if (map.get(parsed)) |val|
            {
                try map.put(parsed, val + 1);
            }
            else
            {
                try map.put(parsed, 1);
            }
        }
    }
    var secondMap = Map(u64, u64).init(gpa);

    for (0..iters) |iter|
    {
        _ = iter;
        var it = map.keyIterator();
        while (it.next()) |k|
        {
            const key = k.*;
            const count = map.get(key).?;
            if (key == 0)
            {
                if (secondMap.get(1)) |val|
                {
                    try secondMap.put(1, val + count);
                }
                else
                {
                    try secondMap.put(1, count);
                }
            }
            else
            {
                const digitCount = std.math.log10(key) + 1;
                if (digitCount & 1 == 0)
                {
                    var halfThreshold: u64 = 1;
                    for (0..(digitCount / 2)) |_|
                    {
                        halfThreshold *= 10;
                    }
                    const leftHalf = key / halfThreshold;
                    const rightHalf = key % halfThreshold;
                    if (secondMap.get(leftHalf)) |val|
                    {
                        try secondMap.put(leftHalf, val + count);
                    }
                    else
                    {
                        try secondMap.put(leftHalf, count);
                    }

                    if (secondMap.get(rightHalf)) |val|
                    {
                        try secondMap.put(rightHalf, val + count);
                    }
                    else
                    {
                        try secondMap.put(rightHalf, count);
                    }
                }
                else
                {
                    const newVal = key * 2024;
                    if (secondMap.get(newVal)) |val|
                    {
                        try secondMap.put(newVal, val + count);
                    }
                    else
                    {
                        try secondMap.put(newVal, count);
                    }
                }
            }
        }

        map.clearRetainingCapacity();
        var it2 = secondMap.keyIterator();
        while (it2.next()) |key|
        {
            try map.put(key.*, secondMap.get(key.*).?);
        }
        secondMap.clearRetainingCapacity();
    }

    var total: u64 = 0;
    {
        var it = map.valueIterator();
        while (it.next()) |val|
        {
            total += val.*;
        }
    }

    return total;
}

pub fn part1() !void
{
    try stdout.print("Part 1: {}\n", .{try solve(25)});
}

pub fn part2() !void
{
    try stdout.print("Part 2: {}\n", .{try solve(75)});
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
