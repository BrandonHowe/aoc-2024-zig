const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day20.txt");
const stdout = std.io.getStdOut().writer();

const QueueItem = struct
{
    x: usize,
    y: usize
};

pub fn computeDistances() ![][]i16
{
    const grid = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(grid);
    const width = grid[0].len;
    var start_pos: usize = 0;
    var end_pos: usize = 0;
    for (grid, 0..) |line, y|
    {
        for (line, 0..) |char, x|
        {
            if (char == 'S') start_pos = y * width + x;
            if (char == 'E') end_pos = y * width + x;
        }
    }

    var visitedGrid = try gpa.alloc([]i16, grid.len);
    for (visitedGrid) |*row|
    {
        row.* = try gpa.alloc(i16, width);

        for (row.*) |*cell| {
            cell.* = -1;
        }
    }

    var visited = Map(QueueItem, bool).init(gpa);
    defer visited.clearAndFree();
    var queue = List(QueueItem).init(gpa);
    defer queue.clearAndFree();
    var next = List(QueueItem).init(gpa);
    defer next.clearAndFree();
    const startItem: QueueItem = QueueItem{
        .x = start_pos % width,
        .y = start_pos / width
    };
    try queue.append(startItem);
    try visited.put(startItem, true);
    visitedGrid[startItem.y][startItem.x] = 0;
    var iter: i16 = 0;
    mainLoop: while (queue.items.len > 0)
    {
        iter += 1;
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                break :mainLoop;
            }
        }
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                continue;
            }
            if (node.x > 0 and grid[node.y][node.x - 1] != '#')
            {
                const item = QueueItem{
                    .x = node.x - 1,
                    .y = node.y,
                };
                var canAdd = !visited.contains(item);
                for (next.items) |i|
                {
                    if (std.meta.eql(i, item)) canAdd = false;
                }
                if (canAdd) try next.append(item);
            }
            if (node.x < width - 1 and grid[node.y][node.x + 1] != '#')
            {
                const item = QueueItem{
                    .x = node.x + 1,
                    .y = node.y,
                };
                var canAdd = !visited.contains(item);
                for (next.items) |i|
                {
                    if (std.meta.eql(i, item)) canAdd = false;
                }
                if (canAdd) try next.append(item);
            }
            if (node.y > 0 and grid[node.y - 1][node.x] != '#')
            {
                const item = QueueItem{
                    .x = node.x,
                    .y = node.y - 1,
                };
                var canAdd = !visited.contains(item);
                for (next.items) |i|
                {
                    if (std.meta.eql(i, item)) canAdd = false;
                }
                if (canAdd) try next.append(item);
            }
            if (node.y < grid.len - 1 and grid[node.y + 1][node.x] != '#')
            {
                const item = QueueItem{
                    .x = node.x,
                    .y = node.y + 1,
                };
                var canAdd = !visited.contains(item);
                for (next.items) |i|
                {
                    if (std.meta.eql(i, item)) canAdd = false;
                }
                if (canAdd) try next.append(item);
            }
        }
        queue.clearRetainingCapacity();
        for (next.items) |item|
        {
            if (grid[item.y][item.x] == '#') continue;
            try queue.append(item);
            try visited.put(item, true);
            visitedGrid[item.y][item.x] = iter;
        }
        next.clearRetainingCapacity();
    }

    return visitedGrid;
}

pub fn part1(visitedGrid: [][]i16) !void
{
    const width = visitedGrid[0].len;
    var diffs = List(i16).init(gpa);
    defer diffs.clearAndFree();
    for (0..visitedGrid.len) |y|
    {
        for (0..width) |x|
        {
            const val = visitedGrid[y][x];
            if (val == -1) continue;
            if (x < width - 2)
            {
                const valR = visitedGrid[y][x + 2];
                if (valR != -1)
                {
                    const diff = valR - val;
                    const absDiff = if (diff < 0) -diff else diff;
                    if (absDiff > 2) try diffs.append(absDiff - 2);
                }
            }
            if (y < visitedGrid.len - 2)
            {
                const valD = visitedGrid[y + 2][x];
                if (valD != -1)
                {
                    const diff = valD - val;
                    const absDiff = if (diff < 0) -diff else diff;
                    if (absDiff > 2) try diffs.append(absDiff - 2);
                }
            }
        }
    }

    var total: u32 = 0;
    for (diffs.items) |diff|
    {
        if (diff >= 100) total += 1;
    }

    try stdout.print("Part 1: {any}\n", .{total});
}

pub fn part2(visitedGrid: [][]i16) !void
{
    const width = visitedGrid[0].len;
    var diffs = List(i32).init(gpa);
    defer diffs.clearAndFree();
    var y: i32 = 0;
    const range = 20;
    var total: u32 = 0;
    while (y < visitedGrid.len) : (y += 1)
    {
        var x: i32 = 0;
        while (x < width) : (x += 1)
        {
            const val = visitedGrid[@as(usize, @intCast(y))][@as(usize, @intCast(x))];
            if (val == -1) continue;
            
            var dy: i32 = -range;
            while (dy <= range) : (dy += 1)
            {
                if (y + dy < 0 or y + dy >= visitedGrid.len) continue;
                const absYDiff: i32 = if (dy < 0) -dy else dy;
                var dx: i32 = -range;
                while (dx <= range) : (dx += 1)
                {
                    const absXDiff: i32 = if (dx < 0) -dx else dx;
                    if (x + dx < 0 or x + dx >= width) continue;
                    if (absXDiff + absYDiff > range) continue;

                    const val2 = visitedGrid[@as(usize, @intCast(y + dy))][@as(usize, @intCast(x + dx))];
                    if (val2 == -1) continue;
                    const diff = val2 - val;
                    const result = diff - (absYDiff + absXDiff);
                    if (result >= 100) total += 1;
                }
            }
        }
    }

    try stdout.print("Part 2: {any}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    const grid = try computeDistances();
    const t1 = std.time.milliTimestamp();
    try stdout.print("Computing distances: {}ms\n", .{t1 - t0});
    try part1(grid);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(grid);
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
