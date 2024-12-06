const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day06.txt");
const stdout = std.io.getStdOut().writer();

const Vec2 = struct {
    x: i16,
    y: i16
};

const Vec3 = struct {
    x: i16,
    y: i16,
    z: i16
};

pub fn part1(obstacles: List(Vec2), startingGuardPos: Vec2, width: i16, height: i16) !Map(Vec2, bool)
{
    var guardPos = startingGuardPos;
    var guardDir: i8 = 0;
    var reached: Map(Vec2, bool) = Map(Vec2, bool).init(gpa);
    mover: while (true)
    {
        if (guardDir == 0)
        {
            var largestY: i16 = -10000;
            for (obstacles.items) |obstacle|
            {
                if (obstacle.x == guardPos.x and obstacle.y < guardPos.y and obstacle.y > largestY) largestY = obstacle.y;
            }
            if (largestY == -10000) break;
            for (@intCast(largestY + 1)..@intCast(guardPos.y + 1)) |y|
            {
                try reached.put(Vec2{ .x = guardPos.x, .y = @intCast(y) }, true);
            }
            guardPos.y = largestY + 1;
            guardDir += 1;
            continue :mover;
        }
        if (guardDir == 1)
        {
            var smallestX: i16 = 10000;
            for (obstacles.items) |obstacle|
            {
                if (obstacle.x > guardPos.x and obstacle.y == guardPos.y and obstacle.x < smallestX) smallestX = obstacle.x;
            }
            if (smallestX == 10000) break;
            for (@intCast(guardPos.x)..@intCast(smallestX)) |x|
            {
                try reached.put(Vec2{ .x = @intCast(x), .y = guardPos.y }, true);
            }
            guardPos.x = smallestX - 1;
            guardDir += 1;
            continue :mover;
        }
        if (guardDir == 2)
        {
            var smallestY: i16 = 10000;
            for (obstacles.items) |obstacle|
            {
                if (obstacle.x == guardPos.x and obstacle.y > guardPos.y and obstacle.y < smallestY) smallestY = obstacle.y;
            }
            if (smallestY == 10000) break;
            for (@intCast(guardPos.y)..@intCast(smallestY)) |y|
            {
                try reached.put(Vec2{ .x = guardPos.x, .y = @intCast(y) }, true);
            }
            guardPos.y = smallestY - 1;
            guardDir += 1;
            continue :mover;
        }
        if (guardDir == 3)
        {
            var largestX: i16 = -10000;
            for (obstacles.items) |obstacle|
            {
                if (obstacle.x < guardPos.x and obstacle.y == guardPos.y and obstacle.x > largestX) largestX = obstacle.x;
            }
            for (@intCast(largestX + 1)..@intCast(guardPos.x + 1)) |x|
            {
                try reached.put(Vec2{ .x = @intCast(x), .y = guardPos.y }, true);
            }
            if (largestX == -10000) break;
            guardPos.x = largestX + 1;
            guardDir = 0;
            continue :mover;
        }
        break;
    }
    if (guardDir == 0)
    {
        for (0..@intCast(guardPos.y)) |y|
        {
            try reached.put(Vec2{ .x = guardPos.x, .y = @intCast(y) }, true);
        }
    }
    if (guardDir == 1)
    {
        for (@intCast(guardPos.x)..@intCast(width + 1)) |x|
        {
            try reached.put(Vec2{ .x = @intCast(x), .y = guardPos.y }, true);
        }
    }
    if (guardDir == 2)
    {
        for (@intCast(guardPos.y)..@intCast(height + 1)) |y|
        {
            try reached.put(Vec2{ .x = guardPos.x, .y = @intCast(y) }, true);
        }
    }
    if (guardDir == 3)
    {
        for (0..@intCast(guardPos.x)) |x|
        {
            try reached.put(Vec2{ .x = @intCast(x), .y = guardPos.y }, true);
        }
    }
    try stdout.print("Part 1: {}\n", .{reached.count()});
    return reached;
}

pub fn part2(obstacles: *List(Vec2), startingGuardPos: Vec2, part1Reached: Map(Vec2, bool)) !void
{
    try obstacles.append(Vec2{ .x = 0, .y = 0 });
    var optionCount: i16 = 0;
    var reached: Map(Vec3, bool) = Map(Vec3, bool).init(gpa);
    var iterator = part1Reached.keyIterator();
    addedObstacleLoop: while (iterator.next()) |ob|
    {
        const newOb = ob.*;
        reached.clearRetainingCapacity();
        var guardPos = startingGuardPos;
        var guardDir: i8 = 0;
        _ = obstacles.pop();
        try obstacles.append(Vec2{ .x = newOb.x, .y = newOb.y });
        mover: while (true)
        {
            if (guardDir == 0)
            {
                var largestY: i16 = -10000;
                for (obstacles.items) |obstacle|
                {
                    if (obstacle.x == guardPos.x and obstacle.y < guardPos.y and obstacle.y > largestY) largestY = obstacle.y;
                }
                if (largestY == -10000) break;
                for (@intCast(largestY + 1)..@intCast(guardPos.y + 1)) |y|
                {
                    const vec = Vec3{ .x = guardPos.x, .y = @intCast(y), .z = guardDir };
                    if (reached.contains(vec))
                    {
                        optionCount += 1;
                        continue :addedObstacleLoop;
                    }
                    try reached.put(vec, true);
                }
                guardPos.y = largestY + 1;
                guardDir += 1;
                continue :mover;
            }
            if (guardDir == 1)
            {
                var smallestX: i16 = 10000;
                for (obstacles.items) |obstacle|
                {
                    if (obstacle.x > guardPos.x and obstacle.y == guardPos.y and obstacle.x < smallestX) smallestX = obstacle.x;
                }
                if (smallestX == 10000) break;
                for (@intCast(guardPos.x)..@intCast(smallestX)) |x|
                {
                    const vec = Vec3{ .x = @intCast(x), .y = guardPos.y, .z = guardDir };
                    if (reached.contains(vec))
                    {
                        optionCount += 1;
                        continue :addedObstacleLoop;
                    }
                    try reached.put(vec, true);
                }
                guardPos.x = smallestX - 1;
                guardDir += 1;
                continue :mover;
            }
            if (guardDir == 2)
            {
                var smallestY: i16 = 10000;
                for (obstacles.items) |obstacle|
                {
                    if (obstacle.x == guardPos.x and obstacle.y > guardPos.y and obstacle.y < smallestY) smallestY = obstacle.y;
                }
                if (smallestY == 10000) break;
                for (@intCast(guardPos.y)..@intCast(smallestY)) |y|
                {
                    const vec = Vec3{ .x = guardPos.x, .y = @intCast(y), .z = guardDir };
                    if (reached.contains(vec))
                    {
                        optionCount += 1;
                        continue :addedObstacleLoop;
                    }
                    try reached.put(vec, true);
                }
                guardPos.y = smallestY - 1;
                guardDir += 1;
                continue :mover;
            }
            if (guardDir == 3)
            {
                var largestX: i16 = -10000;
                for (obstacles.items) |obstacle|
                {
                    if (obstacle.x < guardPos.x and obstacle.y == guardPos.y and obstacle.x > largestX) largestX = obstacle.x;
                }
                if (largestX == -10000) break;
                for (@intCast(largestX + 1)..@intCast(guardPos.x + 1)) |x|
                {
                    const vec = Vec3{ .x = @intCast(x), .y = guardPos.y, .z = guardDir };
                    if (reached.contains(vec))
                    {
                        optionCount += 1;
                        continue :addedObstacleLoop;
                    }
                    try reached.put(vec, true);
                }
                guardPos.x = largestX + 1;
                guardDir = 0;
                continue :mover;
            }
            break;
        }
    }
    try stdout.print("Part 2: {}\n", .{optionCount});
}

pub fn main() !void
{
    var guardPos = Vec2{ .x = 0, .y = 0 };
    var obstacles: List(Vec2) = List(Vec2).init(gpa);
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
            if (c == '^')
            {
                guardPos = Vec2{ .x = x, .y = height };
            }
            else if (c == '#')
            {
                try obstacles.append(Vec2{ .x = x, .y = height });
            }
            x += 1;
        }
    }
    const t1 = std.time.milliTimestamp();
    var part1Reached = try part1(obstacles, guardPos, width, height);
    defer part1Reached.clearAndFree();
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(&obstacles, guardPos, part1Reached);
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
