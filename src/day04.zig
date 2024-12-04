const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day04.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1() !void
{
    const lines = try util.splitInputIntoLines(data);
    defer std.heap.page_allocator.free(lines);

    var xmasInstances: i32 = 0;

    for (0..lines.len) |y|
    {
        for (0..(lines[0].len)) |x|
        {
            if (x <= lines[0].len - 4)
            {
                if (std.mem.eql(u8, lines[y][x..(x + 4)], "XMAS")) xmasInstances += 1;
                if (std.mem.eql(u8, lines[y][x..(x + 4)], "SAMX")) xmasInstances += 1;
            }

            if (y <= lines.len - 4)
            {
                const char1 = lines[y][x];
                const char2 = lines[y + 1][x];
                const char3 = lines[y + 2][x];
                const char4 = lines[y + 3][x];
                if (char1 == 'X' and char2 == 'M' and char3 == 'A' and char4 == 'S') xmasInstances += 1;
                if (char1 == 'S' and char2 == 'A' and char3 == 'M' and char4 == 'X') xmasInstances += 1;
            }

            if (y <= lines.len - 4 and x <= lines[0].len - 4)
            {
                const dcr1 = lines[y][x];
                const dcr2 = lines[y + 1][x + 1];
                const dcr3 = lines[y + 2][x + 2];
                const dcr4 = lines[y + 3][x + 3];
                if (dcr1 == 'X' and dcr2 == 'M' and dcr3 == 'A' and dcr4 == 'S') xmasInstances += 1;
                if (dcr1 == 'S' and dcr2 == 'A' and dcr3 == 'M' and dcr4 == 'X') xmasInstances += 1;
            }

            if (x >= 3 and y <= lines.len - 4)
            {
                const dcr1 = lines[y][x];
                const dcr2 = lines[y + 1][x - 1];
                const dcr3 = lines[y + 2][x - 2];
                const dcr4 = lines[y + 3][x - 3];
                if (dcr1 == 'X' and dcr2 == 'M' and dcr3 == 'A' and dcr4 == 'S') xmasInstances += 1;
                if (dcr1 == 'S' and dcr2 == 'A' and dcr3 == 'M' and dcr4 == 'X') xmasInstances += 1;
            }
        }
    }

    try stdout.print("Part 1: {}\n", .{xmasInstances});
}

pub fn part2() !void
{
    const lines = try util.splitInputIntoLines(data);
    defer std.heap.page_allocator.free(lines);

    var xmasInstances: i32 = 0;

    for (0..(lines.len - 2)) |y|
    {
        for (0..(lines[0].len - 2)) |x|
        {
            const tl = lines[y][x];
            const tr = lines[y][x + 2];
            const ce = lines[y + 1][x + 1];
            const bl = lines[y + 2][x];
            const br = lines[y + 2][x + 2];
            if (ce != 'A') continue;
            if ((tl == 'M' and br == 'S') or (tl == 'S' and br == 'M'))
            {
                if ((tr == 'M' and bl == 'S') or (tr == 'S' and bl == 'M'))
                {
                    xmasInstances += 1;
                }
            }
        }
    }

    try stdout.print("Part 2: {}\n", .{xmasInstances});
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
