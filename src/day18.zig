const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day18.txt");
const stdout = std.io.getStdOut().writer();

const Vec2 = struct
{
    x: u8,
    y: u8
};

const width = 70;
const height = 70;

pub fn runLoop(points: Map(Vec2, bool)) !u32
{
    var visited = Map(Vec2, bool).init(gpa);
    defer visited.clearAndFree();
    var current = List(Vec2).init(gpa);
    defer current.clearAndFree();
    var next = Map(Vec2, bool).init(gpa);
    defer next.clearAndFree();
    var iters: u32 = 0;

    const origin: Vec2 = Vec2{ .x = 0, .y = 0 };
    try current.append(origin);
    try visited.put(origin, true);

    return mainLoop: while (true)
    {
        if (current.items.len == 0) break 0;
        iters += 1;
        for (current.items) |item|
        {
            if (item.x > 0)
            {
                const left = Vec2{ .x = item.x - 1, .y = item.y };
                if (!(visited.get(left) orelse false) and !(points.get(left) orelse false))
                {
                    try next.put(left, true);
                }
            }
            if (item.y > 0)
            {
                const top = Vec2{ .x = item.x, .y = item.y - 1 };
                if (!(visited.get(top) orelse false) and !(points.get(top) orelse false))
                {
                    try next.put(top, true);
                }
            }
            if (item.x < width)
            {
                const right = Vec2{ .x = item.x + 1, .y = item.y };
                if (!(visited.get(right) orelse false) and !(points.get(right) orelse false))
                {
                    try next.put(right, true);
                }
            }
            if (item.y < height)
            {
                const bottom = Vec2{ .x = item.x, .y = item.y + 1 };
                if (!(visited.get(bottom) orelse false) and !(points.get(bottom) orelse false))
                {
                    try next.put(bottom, true);
                }
            }
        }
        current.clearRetainingCapacity();
        var it = next.keyIterator();
        while (it.next()) |item|
        {
            if (item.x == width and item.y == height) break :mainLoop iters;
            try current.append(item.*);
            try visited.put(item.*, true);
        }
        next.clearRetainingCapacity();
    };
}

pub fn part1() !void
{
    var points = Map(Vec2, bool).init(gpa);
    defer points.clearAndFree();
    var lines = splitSca(u8, data, '\n');
    while (lines.next()) |line|
    {
        if (points.count() >= 1024) break;
        var splitLine = splitSca(u8, line, ',');
        const x = try parseInt(u8, splitLine.next().?, 10);
        const y = try parseInt(u8, splitLine.next().?, 10);
        try points.put(Vec2{ .x = x, .y = y }, true);
    }

    const res = try runLoop(points);
    
    try stdout.print("Part 1: {}\n", .{res});
}

pub fn part2() !void
{
    var points = Map(Vec2, bool).init(gpa);
    defer points.clearAndFree();
    var lines = splitSca(u8, data, '\n');
    const killingPoint = blk: {
        while (lines.next()) |line|
        {
            var splitLine = splitSca(u8, line, ',');
            const x = try parseInt(u8, splitLine.next().?, 10);
            const y = try parseInt(u8, splitLine.next().?, 10);
            try points.put(Vec2{ .x = x, .y = y }, true);
            if (points.count() >= 1024 and try runLoop(points) == 0)
            {
                break :blk Vec2{ .x = x, .y = y };
            }
        }
        break :blk Vec2{ .x = 0, .y = 0 };
    };
    try stdout.print("Part 2: {},{}\n", .{killingPoint.x, killingPoint.y});
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
