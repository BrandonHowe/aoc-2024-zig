const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day03.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1() !void {
    var slice: []const u8 = data[0..];
    var total: i32 = 0;
    while (slice.len > 3)
    {
        if (std.mem.eql(u8, "mul", slice[0..3]))
        {
            var left: i32 = 0;
            var right: i32 = 0;
            slice = slice[3..];
            if (slice[0] != '(')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            while (slice[0] >= '0' and slice[0] <= '9')
            {
                left *= 10;
                left += slice[0] - '0';
                slice = slice[1..];
            }
            if (slice[0] != ',')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            while (slice[0] >= '0' and slice[0] <= '9')
            {
                right *= 10;
                right += slice[0] - '0';
                slice = slice[1..];
            }
            if (slice[0] != ')')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            total += left * right;
        }
        else {
            slice = slice[1..];
        }
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2() !void {

    var slice: []const u8 = data[0..];
    var total: i32 = 0;
    var mulEnabled = true;
    while (slice.len > 6)
    {
        if (std.mem.eql(u8, "do()", slice[0..4]))
        {
            mulEnabled = true;
            slice = slice[4..];
        }
        else if (std.mem.eql(u8, "don't()", slice[0..7]))
        {
            mulEnabled = false;
            slice = slice[6..];
        }
        else if (mulEnabled and std.mem.eql(u8, "mul", slice[0..3]))
        {
            var left: i32 = 0;
            var right: i32 = 0;
            slice = slice[3..];
            if (slice[0] != '(')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            while (slice[0] >= '0' and slice[0] <= '9')
            {
                left *= 10;
                left += slice[0] - '0';
                slice = slice[1..];
            }
            if (slice[0] != ',')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            while (slice[0] >= '0' and slice[0] <= '9')
            {
                right *= 10;
                right += slice[0] - '0';
                slice = slice[1..];
            }
            if (slice[0] != ')')
            {
                continue;
            }
            else
            {
                slice = slice[1..];
            }
            total += left * right;
        }
        else {
            slice = slice[1..];
        }
    }
    try stdout.print("Part 2: {}\n", .{total});
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
