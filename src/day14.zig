const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day14.txt");
const stdout = std.io.getStdOut().writer();

const Robot = struct
{
    posX: i32,
    posY: i32,
    velX: i32,
    velY: i32
};

pub fn part1(robotsBase: []Robot) !void
{
    var robots = try gpa.alloc(Robot, robotsBase.len);
    defer gpa.free(robots);
    for (robotsBase, 0..) |robot, i|
    {
        robots[i] = robot;
    }
    var q1: i32 = 0;
    var q2: i32 = 0;
    var q3: i32 = 0;
    var q4: i32 = 0;
    for (robots) |*robot|
    {
        robot.posX = @mod(robot.posX + 100 * robot.velX, 101);
        robot.posY = @mod(robot.posY + 100 * robot.velY, 103);
        if (robot.posX < 50 and robot.posY < 51) q1 += 1;
        if (robot.posX > 50 and robot.posY < 51) q2 += 1;
        if (robot.posX < 50 and robot.posY > 51) q3 += 1;
        if (robot.posX > 50 and robot.posY > 51) q4 += 1;
    }
    const total = q1 * q2 * q3 * q4;
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(robotsBase: []Robot) !void
{
    var robots = try gpa.alloc(Robot, robotsBase.len);
    defer gpa.free(robots);
    for (robotsBase, 0..) |robot, i|
    {
        robots[i] = robot;
    }
    var iter: u64 = 0;
    while (true)
    {
        iter += 1;
        for (robots) |*robot|
        {
            robot.posX = @mod(robot.posX + robot.velX, 101);
            robot.posY = @mod(robot.posY + robot.velY, 103);
        }
        var duplicateFound = false;
        duplicateFinder: for (robots, 0..) |robot, i|
        {
            for ((i + 1)..robots.len) |j|
            {
                const robot2 = robots[j];
                if (robot.posX == robot2.posX and robot.posY == robot2.posY)
                {
                    duplicateFound = true;
                    break :duplicateFinder;
                }
            }
        }
        if (!duplicateFound)
        {
            for (0..103) |y|
            {
                for (0..101) |x|
                {
                    var robotFound = false;
                    for (robots) |robot|
                    {
                        if (robot.posX == x and robot.posY == y)
                        {
                            // try stdout.writeByte('#');
                            robotFound = true;
                            break;
                        }
                    }
                    // if (!robotFound) try stdout.writeByte('.');
                }
                // try stdout.writeByte('\n');
            }
            // try stdout.writeByte('\n');
            break;
        }
    }
    try stdout.print("Part 2: {}\n", .{iter});
}

pub fn main() !void
{
    const lines = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(lines);
    var robots = try gpa.alloc(Robot, lines.len);
    defer gpa.free(robots);
    for (lines, 0..) |line, i|
    {
        var splitLine = splitSca(u8, line, ' ');
        const posStr = splitLine.next().?;
        const velStr = splitLine.next().?;

        var splitPos = splitSca(u8, posStr, ',');
        const posX = try parseInt(i32, splitPos.next().?[2..], 10);
        const posY = try parseInt(i32, splitPos.next().?, 10);

        var splitVel = splitSca(u8, velStr, ',');
        const velX = try parseInt(i32, splitVel.next().?[2..], 10);
        const velY = try parseInt(i32, splitVel.next().?, 10);

        robots[i] = Robot{ .posX = posX, .posY = posY, .velX = velX, .velY = velY };
    }
    const t1 = std.time.milliTimestamp();
    try part1(robots);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(robots);
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
