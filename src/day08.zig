const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day08.txt");
const stdout = std.io.getStdOut().writer();

const Antenna = struct
{
    x: i16,
    y: i16,
    char: u8
};

pub fn part1(antennas: List(Antenna), width: i16, height: i16) !void
{
    var overlaps = Map(Antenna, bool).init(gpa);
    defer overlaps.clearAndFree();
    for (antennas.items) |baseAntenna|
    {
        for (antennas.items) |pairAntenna|
        {
            if (baseAntenna.char != pairAntenna.char) continue;
            if (baseAntenna.x == pairAntenna.x and baseAntenna.y == pairAntenna.y) continue;
            const dx = pairAntenna.x - baseAntenna.x;
            const dy = pairAntenna.y - baseAntenna.y;
            const a1 = Antenna{ .x = baseAntenna.x - dx, .y = baseAntenna.y - dy, .char = ' ' };
            const a2 = Antenna{ .x = pairAntenna.x + dx, .y = pairAntenna.y + dy, .char = ' ' };
            try overlaps.put(a1, true);
            try overlaps.put(a2, true);
        }
    }
    var total: i16 = 0;
    var it = overlaps.keyIterator();
    while (it.next()) |overlap|
    {
        if (overlap.x >= 0 and overlap.y >= 0 and overlap.x < width and overlap.y < height)
        {
            total += 1;
        }
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(antennas: List(Antenna), width: i16, height: i16) !void
{
    var overlaps = Map(Antenna, bool).init(gpa);
    defer overlaps.clearAndFree();
    for (antennas.items) |baseAntenna|
    {
        for (antennas.items) |pairAntenna|
        {
            if (baseAntenna.char != pairAntenna.char) continue;
            if (baseAntenna.x == pairAntenna.x and baseAntenna.y == pairAntenna.y) continue;
            const dx = pairAntenna.x - baseAntenna.x;
            const dy = pairAntenna.y - baseAntenna.y;
            var a1 = Antenna{ .x = baseAntenna.x, .y = baseAntenna.y, .char = ' ' };
            try overlaps.put(a1, true);
            while (a1.x >= 0 and a1.y >= 0 and a1.x < width and a1.y < height)
            {
                a1 = Antenna{ .x = a1.x - dx, .y = a1.y - dy, .char = ' ' };
                try overlaps.put(a1, true);
            }
            var a2 = Antenna{ .x = pairAntenna.x, .y = pairAntenna.y, .char = ' ' };
            try overlaps.put(a2, true);
            while (a2.x >= 0 and a2.y >= 0 and a2.x < width and a2.y < height)
            {
                a2 = Antenna{ .x = a2.x + dx, .y = a2.y + dy, .char = ' ' };
                try overlaps.put(a2, true);
            }
        }
    }
    var total: i16 = 0;
    var it = overlaps.keyIterator();
    while (it.next()) |overlap|
    {
        if (overlap.x >= 0 and overlap.y >= 0 and overlap.x < width and overlap.y < height)
        {
            total += 1;
        }
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    var antennas: List(Antenna) = List(Antenna).init(gpa);
    defer antennas.clearAndFree();
    var x: i16 = 0;
    var height: i16 = 0;
    var width: i16 = 0;
    for (data) |c|
    {
        if (c == '\n')
        {
            width = x;
            height += 1;
            x = 0;
        }
        else
        {
            if (c != '.')
            {
                try antennas.append(Antenna{ .x = x, .y = height, .char = c });
            }
            x += 1;
        }
    }
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(antennas, width, height);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(antennas, width, height);
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
