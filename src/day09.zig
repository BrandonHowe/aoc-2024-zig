const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day09.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1() !void
{
    var totalBytes: u32 = 0;
    var contentBytes: u32 = 0;
    for (data, 0..) |c, i|
    {
        totalBytes += c - '0';
        if (i % 2 == 0) contentBytes += c - '0';
    }
    var filesystem: []i16 = try gpa.alloc(i16, totalBytes);
    defer gpa.free(filesystem);
    {
        var head: u32 = 0;
        var fileIdx: i16 = 0;
        for (data, 0..) |c, i|
        {
            const bytes = c - '0';
            for (0..bytes) |j|
            {
                filesystem[head + j] = if (i % 2 == 1) -1 else fileIdx;
            }
            if (i % 2 == 0)
            {
                fileIdx += 1;
            }
            head += bytes;
        }
    }
    {
        var tail: u32 = totalBytes - 1;
        var head: u32 = 0;
        while (tail >= contentBytes)
        {
            if (filesystem[tail] == -1)
            {
                tail -= 1;
                continue;
            }
            firstEmptySlotFinder: for (head..filesystem.len) |i|
            {
                if (filesystem[i] == -1)
                {
                    filesystem[i] = filesystem[tail];
                    filesystem[tail] = -1;
                    head = @intCast(i + 1);
                    break :firstEmptySlotFinder;
                }
            }
            tail -= 1;
        }
    }
    var checksum: i128 = 0;
    for (0..contentBytes) |i|
    {
        checksum += @as(i128, filesystem[i]) * @as(i128, i);
    }
    try stdout.print("Part 1: {}\n", .{checksum});
}

const File = struct
{
    id: i16,
    len: u8
};

pub fn part2() !void
{
    var totalBytes: u32 = 0;
    var contentBytes: u32 = 0;
    for (data, 0..) |c, i|
    {
        totalBytes += c - '0';
        if (i % 2 == 0) contentBytes += c - '0';
    }
    var filesystem: List(File) = List(File).init(gpa);
    defer filesystem.clearAndFree();

    var fileIdx: i16 = 0;
    for (data, 0..) |c, i|
    {
        const bytes = c - '0';
        try filesystem.append(File{ .id = if (i % 2 == 1) -1 else fileIdx, .len = bytes });
        if (i % 2 == 0)
        {
            fileIdx += 1;
        }
    }

    fileIdx -= 1;
    while (fileIdx > 0)
    {
        var file: File = undefined;
        var filePos: u32 = 0;
        for (filesystem.items, 0..) |f, i|
        {
            if (f.id == fileIdx)
            {
                file = f;
                filePos = @intCast(i);
                break;
            }
        }
        for (filesystem.items, 0..) |*block, i|
        {
            if (i >= filePos) break;
            if (block.id == -1)
            {
                if (block.len == file.len)
                {
                    block.id = file.id;
                    filesystem.items[filePos].id = -1;
                    break;
                }
                if (block.len >= file.len)
                {
                    block.len -= file.len;
                    filesystem.items[filePos].id = -1;
                    try filesystem.insert(i, file);
                    break;
                }
            }
        }
        fileIdx -= 1;
    }

    var checksum: i128 = 0;
    var head: usize = 0;
    for (filesystem.items) |file|
    {
        if (file.id != -1)
        {
            for (0..file.len) |i|
            {
                checksum += @as(i128, file.id) * @as(i128, head + i);
            }
        }
        head += file.len;
    }
    
    try stdout.print("Part 2: {}\n", .{checksum});
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
