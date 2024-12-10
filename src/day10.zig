const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day10.txt");
const stdout = std.io.getStdOut().writer();

pub fn trailPaths(grid: List(i8), width: usize, height: usize, start: usize, end: usize, allocator: Allocator) !u32
{
    if (grid.items[start] != 0 or grid.items[end] != 9) return 0;
    var next = List(usize).init(allocator);
    defer next.clearAndFree();
    var queue = List(usize).init(allocator);
    defer queue.clearAndFree();
    try next.append(start);
    for (1..10) |i|
    {
        for (next.items) |pos|
        {
            if (pos % width != 0 and grid.items[pos - 1] == i) try queue.append(pos - 1);
            if ((pos + 1) % width != 0 and grid.items[pos + 1] == i) try queue.append(pos + 1);
            if (pos / width > 0 and grid.items[pos - width] == i) try queue.append(pos - width);
            if (pos / width < height - 1 and grid.items[pos + width] == i) try queue.append(pos + width);
        }
        next.clearRetainingCapacity();
        for (queue.items) |pos|
        {
            if (grid.items[pos] == i) try next.append(pos);
        }
        queue.clearRetainingCapacity();
    }
    var total: u32 = 0;
    for (next.items) |p|
    {
        if (p == end) total += 1;
    }
    return total;
}

pub fn part1(grid: List(i8), width: usize, height: usize) !void
{
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();
    var heads = List(usize).init(gpa);
    defer heads.clearAndFree();
    var tails = List(usize).init(gpa);
    defer tails.clearAndFree();
    for (grid.items, 0..) |c, i|
    {
        if (c == 0) try heads.append(i);
        if (c == 9) try tails.append(i);
    }
    var total: i16 = 0;
    for (heads.items) |head|
    {
        for (tails.items) |tail|
        {
            const valid = try trailPaths(grid, width, height, head, tail, allocator);
            if (valid > 0) total += 1;
        }
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(grid: List(i8), width: usize, height: usize) !void
{
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();
    var heads = List(usize).init(gpa);
    defer heads.clearAndFree();
    var tails = List(usize).init(gpa);
    defer tails.clearAndFree();
    for (grid.items, 0..) |c, i|
    {
        if (c == 0) try heads.append(i);
        if (c == 9) try tails.append(i);
    }
    var total: u32 = 0;
    for (heads.items) |head|
    {
        for (tails.items) |tail|
        {
            total += try trailPaths(grid, width, height, head, tail, allocator);
        }
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    var grid = std.ArrayList(i8).init(gpa);
    defer grid.deinit();
    var height: usize = 0;
    for (data) |c|
    {
        if (c != '\n')
        {
            try grid.append(@intCast(c - '0'));
        }
        else
        {
            height += 1;
        }
    }
    const width = grid.items.len / height;
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(grid, width, height);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(grid, width, height);
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
