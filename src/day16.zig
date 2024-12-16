const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day16.txt");
const stdout = std.io.getStdOut().writer();

const Vec2 = struct
{
    x: usize,
    y: usize
};

const QueueItem = struct
{
    x: usize,
    y: usize,
    dir: i8,
    score: i32
};

const QueueItemP2 = struct
{
    x: usize,
    y: usize,
    dir: i8,
    score: i32,
    history: [512]Vec2,
    historyLen: u16
};

pub fn part1(grid: [][]const u8) !i32
{
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
    var visited = Map(usize, i32).init(gpa);
    defer visited.clearAndFree();
    var queue = List(QueueItem).init(gpa);
    defer queue.clearAndFree();
    var next = List(QueueItem).init(gpa);
    defer next.clearAndFree();
    try queue.append(QueueItem{
        .dir = 1,
        .score = 0,
        .x = start_pos % width,
        .y = start_pos / width
    });
    try visited.put(start_pos, 0);
    var minScore: i32 = 999999999;
    while (queue.items.len > 0)
    {
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                if (node.score < minScore) minScore = node.score;
            }
        }
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                continue;
            }
            if (grid[node.y][node.x - 1] != '#' and node.dir != 1)
            {
                var dirDiff: i32 = @mod(3 - node.dir, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                var canAdd = if (visited.get(node.y * width + node.x - 1)) |score| score > newScore else true;
                for (next.items) |item|
                {
                    if (item.x == node.x - 1 and item.y == node.y and item.score < newScore) canAdd = false;
                }
                if (canAdd)
                {
                    const item = QueueItem{
                        .dir = 3,
                        .score = newScore,
                        .x = node.x - 1,
                        .y = node.y
                    };
                    try next.append(item);
                }
            }
            if (grid[node.y][node.x + 1] != '#' and node.dir != 3)
            {
                var dirDiff: i32 = @mod(1 - node.dir, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                var canAdd = if (visited.get(node.y * width + node.x + 1)) |score| score > newScore else true;
                for (next.items) |item|
                {
                    if (item.x == node.x + 1 and item.y == node.y and item.score < newScore) canAdd = false;
                }
                if (canAdd)
                {
                    const item = QueueItem{
                        .dir = 1,
                        .score = newScore,
                        .x = node.x + 1,
                        .y = node.y
                    };
                    try next.append(item);
                }
            }
            if (grid[node.y - 1][node.x] != '#' and node.dir != 2)
            {
                var dirDiff: i32 = node.dir;
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                var canAdd = if (visited.get((node.y - 1) * width + node.x)) |score| score > newScore else true;
                for (next.items) |item|
                {
                    if (item.x == node.x and item.y == node.y - 1 and item.score < newScore) canAdd = false;
                }
                if (canAdd)
                {
                    const item = QueueItem{
                        .dir = 0,
                        .score = newScore,
                        .x = node.x,
                        .y = node.y - 1
                    };
                    try next.append(item);
                }
            }
            if (grid[node.y + 1][node.x] != '#' and node.dir != 0)
            {
                var dirDiff: i32 = @mod(node.dir - 2, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                var canAdd = if (visited.get((node.y + 1) * width + node.x)) |score| score > newScore else true;
                for (next.items) |item|
                {
                    if (item.x == node.x and item.y == node.y + 1 and item.score < newScore) canAdd = false;
                }
                if (canAdd)
                {
                    const item = QueueItem{
                        .dir = 2,
                        .score = newScore,
                        .x = node.x,
                        .y = node.y + 1
                    };
                    try next.append(item);
                }
            }
        }
        queue.clearRetainingCapacity();
        for (next.items) |item|
        {
            try queue.append(item);
            try visited.put(item.y * width + item.x, item.score);
        }
        next.clearRetainingCapacity();
    }
    try stdout.print("Part 1: {}\n", .{minScore});
    return minScore;
}

fn mergeHistories(q1: QueueItemP2, q2: QueueItemP2) QueueItemP2
{
    var new = QueueItemP2{
        .dir = q1.dir,
        .score = q1.score,
        .x = q1.x,
        .y = q1.y,
        .history = q1.history,
        .historyLen = q1.historyLen
    };
    for (0..q2.historyLen) |i|
    {
        const item = q2.history[i];
        const canAdd = for (0..q1.historyLen) |j|
        {
            const item2 = q1.history[j];
            if (item.x == item2.x and item.y == item2.y) break false;
        } else true;
        if (canAdd)
        {
            new.history[new.historyLen] = item;
            new.historyLen += 1;
        }
    }
    std.log.debug("Merging at {}, {}: {any} {any} {}", .{q1.x, q1.y, q1.historyLen, q2.historyLen, new.historyLen});
    return new;
}

pub fn part2(grid: [][]const u8, targetScore: i32) !void
{
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
    var visited = Map(usize, i32).init(gpa);
    defer visited.clearAndFree();
    var queue = List(QueueItemP2).init(gpa);
    defer queue.clearAndFree();
    var next = List(QueueItemP2).init(gpa);
    defer next.clearAndFree();
    try queue.append(QueueItemP2{
        .dir = 1,
        .score = 0,
        .x = start_pos % width,
        .y = start_pos / width,
        .history = std.mem.zeroes([512]Vec2),
        .historyLen = 1
    });
    var bestNodes = List(QueueItemP2).init(gpa);
    defer bestNodes.clearAndFree();
    queue.items[0].history[0] = Vec2{ .x = start_pos % width, .y = start_pos / width };
    try visited.put(start_pos, 0);
    var minScore: i32 = 999999999;
    while (queue.items.len > 0)
    {
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                if (node.score <= minScore)
                {
                    minScore = node.score;
                    try bestNodes.append(node);
                }
            }
        }
        for (queue.items) |node|
        {
            if (node.y == end_pos / width and node.x == end_pos % width)
            {
                continue;
            }
            if (node.score > targetScore) continue;
            if (grid[node.y][node.x - 1] != '#' and node.dir != 1)
            {
                var dirDiff: i32 = @mod(3 - node.dir, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                const canAdd = if (visited.get(node.y * width + node.x - 1)) |score| score > newScore else true;
                if (canAdd)
                {
                    var item = QueueItemP2{
                        .dir = 3,
                        .score = newScore,
                        .x = node.x - 1,
                        .y = node.y,
                        .history = node.history,
                        .historyLen = node.historyLen + 1
                    };
                    item.history[item.historyLen - 1] = Vec2{ .x = item.x, .y = item.y };
                    try next.append(item);
                }
            }
            if (grid[node.y][node.x + 1] != '#' and node.dir != 3)
            {
                var dirDiff: i32 = @mod(1 - node.dir, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                const canAdd = if (visited.get(node.y * width + node.x + 1)) |score| score > newScore else true;
                if (canAdd)
                {
                    var item = QueueItemP2{
                        .dir = 1,
                        .score = newScore,
                        .x = node.x + 1,
                        .y = node.y,
                        .history = node.history,
                        .historyLen = node.historyLen + 1
                    };
                    item.history[item.historyLen - 1] = Vec2{ .x = item.x, .y = item.y };
                    try next.append(item);
                }
            }
            if (grid[node.y - 1][node.x] != '#' and node.dir != 2)
            {
                var dirDiff: i32 = node.dir;
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                const canAdd = if (visited.get((node.y - 1) * width + node.x)) |score| score > newScore else true;
                if (canAdd)
                {
                    var item = QueueItemP2{
                        .dir = 0,
                        .score = newScore,
                        .x = node.x,
                        .y = node.y - 1,
                        .history = node.history,
                        .historyLen = node.historyLen + 1
                    };
                    item.history[item.historyLen - 1] = Vec2{ .x = item.x, .y = item.y };
                    try next.append(item);
                }
            }
            if (grid[node.y + 1][node.x] != '#' and node.dir != 0)
            {
                var dirDiff: i32 = @mod(node.dir - 2, 4);
                if (dirDiff == 3) dirDiff = 1;
                const newScore = node.score + dirDiff * 1000 + 1;
                const canAdd = if (visited.get((node.y + 1) * width + node.x)) |score| score > newScore else true;
                if (canAdd)
                {
                    var item = QueueItemP2{
                        .dir = 2,
                        .score = newScore,
                        .x = node.x,
                        .y = node.y + 1,
                        .history = node.history,
                        .historyLen = node.historyLen + 1
                    };
                    item.history[item.historyLen - 1] = Vec2{ .x = item.x, .y = item.y };
                    try next.append(item);
                }
            }
        }
        queue.clearRetainingCapacity();
        for (next.items) |item|
        {
            try queue.append(item);
            try visited.put(item.y * width + item.x, item.score);
        }
        next.clearRetainingCapacity();
    }
    var history = Map(Vec2, bool).init(gpa);
    defer history.clearAndFree();
    for (bestNodes.items) |node|
    {
        if (node.score != minScore) continue;
        for (0..node.historyLen) |i|
        {
            const historyItem = node.history[i];
            try history.put(historyItem, true);
        }
    }
    try stdout.print("Part 2: {}\n", .{history.count()});
}

pub fn main() !void
{
    const lines = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(lines);
    const t1 = std.time.milliTimestamp();
    const score = try part1(lines);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(lines, score);
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
