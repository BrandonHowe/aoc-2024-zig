const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day15.txt");
const stdout = std.io.getStdOut().writer();

const PosType = enum {
    None,
    Wall,
    Box
};

const Direction = enum {
    Up,
    Right,
    Down,
    Left
};

pub fn part1(grid: []PosType, width: u16, height: u16, startingPos: u32, directions: []Direction) !void
{
    var robotPos = startingPos;
    _ = height;
    for (directions) |dir|
    {
        // try stdout.print("Moving: {}\n", .{dir});
        var canMove = false;
        var boxMoveCount: u8 = 0;
        if (dir == Direction.Up)
        {
            var tempPos = robotPos - width;
            while (tempPos > 0)
            {
                if (grid[tempPos] == PosType.None) { canMove = true; break; }
                else if (grid[tempPos] == PosType.Box) { boxMoveCount += 1; }
                else if (grid[tempPos] == PosType.Wall) break;
                tempPos -= width;
            }
            if (!canMove) continue;

            for (0..boxMoveCount) |i|
            {
                grid[robotPos - 2 * width - (i * width)] = PosType.Box;
            }
            grid[robotPos - width] = PosType.None;
            robotPos -= width;
        }
        else if (dir == Direction.Right)
        {
            var tempPos = robotPos + 1;
            while ((tempPos + 1) % width != 0)
            {
                if (grid[tempPos] == PosType.None) { canMove = true; break; }
                else if (grid[tempPos] == PosType.Box) { boxMoveCount += 1; }
                else if (grid[tempPos] == PosType.Wall) break;
                tempPos += 1;
            }
            if (!canMove) continue;

            for (0..boxMoveCount) |i|
            {
                grid[robotPos + 2 + i] = PosType.Box;
            }
            grid[robotPos + 1] = PosType.None;
            robotPos += 1;
        }
        else if (dir == Direction.Down)
        {
            var tempPos = robotPos + width;
            while (tempPos < grid.len)
            {
                if (grid[tempPos] == PosType.None) { canMove = true; break; }
                else if (grid[tempPos] == PosType.Box) { boxMoveCount += 1; }
                else if (grid[tempPos] == PosType.Wall) break;
                tempPos += width;
            }
            if (!canMove) continue;

            for (0..boxMoveCount) |i|
            {
                grid[robotPos + 2 * width + (i * width)] = PosType.Box;
            }
            grid[robotPos + width] = PosType.None;
            robotPos += width;
        }
        else if (dir == Direction.Left)
        {
            var tempPos = robotPos - 1;
            while ((tempPos + 1) % width != 0)
            {
                if (grid[tempPos] == PosType.None) { canMove = true; break; }
                else if (grid[tempPos] == PosType.Box) { boxMoveCount += 1; }
                else if (grid[tempPos] == PosType.Wall) break;
                tempPos -= 1;
            }
            if (!canMove) continue;

            for (0..boxMoveCount) |i|
            {
                grid[robotPos - 2 - i] = PosType.Box;
            }
            grid[robotPos - 1] = PosType.None;
            robotPos -= 1;
        }
        // for (grid, 0..) |c, i|
        // {
        //     if (robotPos == i) { try stdout.writeByte('@'); continue; }
        //     if (c == PosType.Wall) try stdout.writeByte('#');
        //     if (c == PosType.Box) try stdout.writeByte('O');
        //     if (c == PosType.None) try stdout.writeByte('.');
        //     if ((i + 1) % width == 0) try stdout.writeByte('\n');
        // }
    }
    var total: u64 = 0;
    for (grid, 0..) |c, i|
    {
        if (c != PosType.Box) continue;
        const x = i % width;
        const y = i / width;
        total += y * 100 + x;
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(grid: []PosType, widthRaw: u16, height: u16, startingPos: u32, directions: []Direction) !void
{
    _ = height;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();
    var walls = List(usize).init(gpa);
    defer walls.clearAndFree();
    var boxes = List(usize).init(gpa);
    defer boxes.clearAndFree();

    for (grid, 0..) |c, i|
    {
        if (c == PosType.Wall)
        {
            try walls.append(i * 2);
            try walls.append(i * 2 + 1);
        }
        if (c == PosType.Box)
        {
            try boxes.append(i * 2);
        }
    }

    const width = widthRaw * 2;
    var robotPos = startingPos * 2;
    dirLoop: for (directions) |dir|
    {
        if (dir == Direction.Right or dir == Direction.Left)
        {
            const right = dir == Direction.Right;
            var target = if (right) robotPos + 1 else robotPos - 1;
            var boxIndices = List(*usize).init(allocator);
            defer boxIndices.clearAndFree();
            var canMove = true;
            while (true)
            {
                for (walls.items) |pos|
                {
                    if (pos == target)
                    {
                        canMove = false;
                        break;
                    }
                }
                var foundBox = false;
                for (boxes.items) |*b|
                {
                    if (b.* == target or b.* + 1 == target)
                    {
                        foundBox = true;
                        try boxIndices.append(b);
                    }
                }
                if (!foundBox) break;
                if (right) target += 2 else target -= 2;
            }
            if (canMove)
            {
                for (boxIndices.items) |b|
                {
                    if (right) b.* += 1 else b.* -= 1;
                }
                if (right) robotPos += 1 else robotPos -= 1;
            }
        }
        else if (dir == Direction.Down or dir == Direction.Up)
        {
            const down = dir == Direction.Down;
            const frontOfRobot = if (down) robotPos + width else robotPos - width;
            for (walls.items) |wallPos|
            {
                if (wallPos == frontOfRobot) continue :dirLoop;
            }
            var startingBox: ?*usize = null;
            for (boxes.items) |*boxPos|
            {
                if ((boxPos.* == frontOfRobot) or
                    (boxPos.* + 1 == frontOfRobot)) startingBox = boxPos;
            }
            var canMove = true;
            if (startingBox) |sp|
            {
                var touchedBoxes = List(*usize).init(allocator);
                defer touchedBoxes.clearAndFree();
                var nextBoxes = List(*usize).init(allocator);
                defer nextBoxes.clearAndFree();
                try nextBoxes.append(sp);
                while (nextBoxes.items.len > 0)
                {
                    for (nextBoxes.items) |nextBox|
                    {
                        try touchedBoxes.append(nextBox);
                    }
                    nextBoxes.clearRetainingCapacity();
                    for (touchedBoxes.items) |touchedBox|
                    {
                        for (boxes.items) |*otherBox|
                        {
                            if (std.mem.indexOfScalar(*usize, touchedBoxes.items, otherBox) != null) continue;
                            const dist: i64 = @as(i64, @intCast(otherBox.*)) - @as(i64, @intCast(touchedBox.*));
                            const offset: i64 = if (down) dist - width else width + dist;
                            if (offset == -1 or offset == 0 or offset == 1)
                            {
                                if (std.mem.indexOfScalar(*usize, nextBoxes.items, otherBox) == null) try nextBoxes.append(otherBox);
                            }
                        }
                    }
                }
                canMoveChecker: for (touchedBoxes.items) |touchedBox|
                {
                    for (walls.items) |wall|
                    {
                        const dist: i64 = @as(i64, @intCast(wall)) - @as(i64, @intCast(touchedBox.*));
                        const offset: i64 = if (down) dist - width else width + dist;
                        if (offset == 0 or offset == 1)
                        {
                            canMove = false;
                            break :canMoveChecker;
                        }
                    }
                }
                if (canMove)
                {
                    for (touchedBoxes.items) |box|
                    {
                        if (down) box.* += width else box.* -= width;
                    }
                }
            }
            if (canMove)
            {
                if (down) robotPos += width else robotPos -= width;
            }
        }
    }
    var total: u64 = 0;
    for (boxes.items) |i|
    {
        const x = i % width;
        const y = i / width;
        total += y * 100 + x;
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    var it = splitSeq(u8, data, "\n\n");
    const gridStr = it.next().?;
    var grid = List(PosType).init(gpa);
    defer grid.clearAndFree();
    var x: u8 = 0;
    var width: u16 = 0;
    var height: u16 = 0;
    var robotPos: u32 = 0;
    for (gridStr) |c|
    {
        if (c == '\n')
        {
            height += 1;
            width = x;
            x = 0;
        }
        else
        {
            const posType = if (c == '#') PosType.Wall else if (c == 'O') PosType.Box else PosType.None;
            try grid.append(posType);
            if (c == '@') robotPos = height * width + x;
            x += 1;
        }
    }
    const directionStr = it.next().?;
    var directions = List(Direction).init(gpa);
    defer directions.clearAndFree();
    for (directionStr) |c|
    {
        switch (c)
        {
            '^' => try directions.append(Direction.Up),
            '>' => try directions.append(Direction.Right),
            'v' => try directions.append(Direction.Down),
            '<' => try directions.append(Direction.Left),
            else => {}
        }
    }
    var grid2 = try gpa.alloc(PosType, grid.items.len);
    for (grid.items, 0..) |g, i| grid2[i] = g;
    defer gpa.free(grid2);
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(grid.items, width, height, robotPos, directions.items);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(grid2, width, height, robotPos, directions.items);
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
