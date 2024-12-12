const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day12.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1(grid: []u16, width: usize, height: usize) !void
{
    var areas = Map(u16, u16).init(gpa);
    defer areas.clearAndFree();
    var perimeters = Map(u16, u16).init(gpa);
    defer perimeters.clearAndFree();
    
    for (0..height) |y|
    {
        for (0..width) |x|
        {
            const char = grid[y * width + x];
            if (areas.get(char)) |val|
            {
                try areas.put(char, val + 1);
            }
            else
            {
                try areas.put(char, 1);
            }

            var adjacencies: u16 = 0;
            if (y > 0 and grid[(y - 1) * width + x] == char) adjacencies += 1;
            if (y < height - 1 and grid[(y + 1) * width + x] == char) adjacencies += 1;
            if (x > 0 and grid[y * width + x - 1] == char) adjacencies += 1;
            if (x < width - 1 and grid[y * width + x + 1] == char) adjacencies += 1;

            if (perimeters.get(char)) |val|
            {
                try perimeters.put(char, val + 4 - adjacencies);
            }
            else
            {
                try perimeters.put(char, 4 - adjacencies);
            }
        }
    }

    var total: u64 = 0;
    var it = areas.keyIterator();
    while (it.next()) |char|
    {
        const area = areas.get(char.*);
        const perimeter = perimeters.get(char.*);
        const product: u32 = (area orelse 0) * (perimeter orelse 0);
        total += product;
    }

    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(grid: []u16, width: usize, height: usize, regionCount: u16) !void
{
    var total: u64 = 0;
    for (1..(regionCount + 1)) |region|
    {
        var cornerCount: u16 = 0;
        var area: u16 = 0;
        for (grid, 0..) |char, pos|
        {
            if (char == region)
            {
                area += 1;
                
                const adjLeft = pos % width > 0 and grid[pos - 1] == char;
                const adjRight = pos % width < width - 1 and grid[pos + 1] == char;
                const adjTop = pos / width > 0 and grid[pos - width] == char;
                const adjBottom = pos / width < height - 1 and grid[pos + width] == char;

                var adjCount: u8 = 0;
                if (adjLeft) adjCount += 1;
                if (adjRight) adjCount += 1;
                if (adjTop) adjCount += 1;
                if (adjBottom) adjCount += 1;

                if (adjCount == 0) cornerCount += 4;
                if (adjCount == 1) cornerCount += 2;
                if (adjCount == 2)
                {
                    if (adjLeft != adjRight)
                    {
                        cornerCount += 1;
                        if (adjLeft and adjTop and grid[pos - width - 1] != char) cornerCount += 1;
                        if (adjRight and adjTop and grid[pos - width + 1] != char) cornerCount += 1;
                        if (adjLeft and adjBottom and grid[pos + width - 1] != char) cornerCount += 1;
                        if (adjRight and adjBottom and grid[pos + width + 1] != char) cornerCount += 1;
                    }
                }
                if (adjCount == 3 or adjCount == 4)
                {
                    if (adjLeft and adjTop and grid[pos - width - 1] != char) cornerCount += 1;
                    if (adjRight and adjTop and grid[pos - width + 1] != char) cornerCount += 1;
                    if (adjLeft and adjBottom and grid[pos + width - 1] != char) cornerCount += 1;
                    if (adjRight and adjBottom and grid[pos + width + 1] != char) cornerCount += 1;
                }
            }
        }
        total += cornerCount * area;
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    var grid = std.ArrayList(u8).init(gpa);
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

    var floodFilledGrid = try gpa.alloc(u16, width * height);
    defer gpa.free(floodFilledGrid);
    for (floodFilledGrid) |*c| c.* = 0;

    var queue = List(usize).init(gpa);
    var newQueue = List(usize).init(gpa);

    var regionIdx: u16 = 0;
    while (true)
    {
        queue.clearRetainingCapacity();
        newQueue.clearRetainingCapacity();
        for (0..grid.items.len) |i|
        {
            if (floodFilledGrid[i] == 0)
            {
                try queue.append(i);
                regionIdx += 1;
                floodFilledGrid[i] = regionIdx;
                break;
            }
        }
        if (queue.items.len == 0) break;
        while (queue.items.len > 0)
        {
            for (queue.items) |p|
            {
                const char = grid.items[p];
                if (p % width != 0)
                {
                    if (floodFilledGrid[p - 1] == 0 and grid.items[p - 1] == char)
                    {
                        try newQueue.append(p - 1);
                        floodFilledGrid[p - 1] = regionIdx;
                    }
                }
                if (p % width != width - 1)
                {
                    if (floodFilledGrid[p + 1] == 0 and grid.items[p + 1] == char)
                    {
                        try newQueue.append(p + 1);
                        floodFilledGrid[p + 1] = regionIdx;
                    }
                }
                if (p / width > 0)
                {
                    if (floodFilledGrid[p - width] == 0 and grid.items[p - width] == char)
                    {
                        try newQueue.append(p - width);
                        floodFilledGrid[p - width] = regionIdx;
                    }
                }
                if (p / width < height - 1)
                {
                    if (floodFilledGrid[p + width] == 0 and grid.items[p + width] == char)
                    {
                        try newQueue.append(p + width);
                        floodFilledGrid[p + width] = regionIdx;
                    }
                }
            }
            queue.clearRetainingCapacity();
            for (newQueue.items) |c| try queue.append(c);
            newQueue.clearRetainingCapacity();
        }
    }

    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(floodFilledGrid, width, height);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(floodFilledGrid, width, height, regionIdx);
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
