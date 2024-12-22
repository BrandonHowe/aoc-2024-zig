const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day22.txt");
const stdout = std.io.getStdOut().writer();

pub fn evolve(num: i32) i32
{
    var secret = num;
    const n1 = num << 6;
    secret = secret ^ n1;
    secret = secret & ((1 << 24) - 1);
    const n2 = secret >> 5;
    secret = secret ^ n2;
    secret = secret & ((1 << 24) - 1);
    const n3 = secret << 11;
    secret = secret ^ n3;
    secret = secret & ((1 << 24) - 1);
    return secret;
}

pub fn part1(secrets: []i32) !void
{
    var total: i64 = 0;
    for (secrets) |secret|
    {
        var s = secret;
        for (0..2000) |_| s = evolve(s);
        total += s;
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(secrets: []i32) !void
{
    const iters = 2000;
    var diffs = try gpa.alloc([]i8, secrets.len);
    defer gpa.free(diffs);
    for (diffs) |*row|
    {
        row.* = try gpa.alloc(i8, iters);
    }
    var prices = try gpa.alloc([]u8, secrets.len);
    defer gpa.free(prices);
    for (prices) |*row|
    {
        row.* = try gpa.alloc(u8, iters);
    }
    for (secrets, 0..) |*secret, i|
    {
        var lastSecret: i32 = 0;
        for (0..iters) |j|
        {
            lastSecret = secret.*;
            secret.* = evolve(secret.*);
            const diff = @mod(secret.*, 10) - @mod(lastSecret, 10);
            diffs[i][j] = @as(i8, @intCast(diff));
            prices[i][j] = @as(u8, @intCast(@mod(secret.*, 10)));
        }
    }
    var map = Map([4]i8, u64).init(gpa);
    const buffer = try gpa.alloc(u8, 100000);
    defer gpa.free(buffer);
    var fba = std.heap.FixedBufferAllocator.init(buffer);
    const allocator = fba.allocator();
    for (diffs, 0..) |row, rowIdx|
    {
        var diffsInRow = Map([4]i8, bool).init(allocator);
        defer diffsInRow.clearAndFree();
        for (0..(row.len - 4)) |i|
        {
            var seq = [4]i8{ 0, 0, 0, 0 };
            std.mem.copyForwards(i8, &seq, row[i..(i + 4)]);
            if (diffsInRow.contains(seq))
            {
                continue;
            }
            else
            {
                try diffsInRow.put(seq, true);
                if (map.get(seq)) |v|
                {
                    try map.put(seq, v + prices[rowIdx][i + 3]);
                }
                else
                {
                    try map.put(seq, prices[rowIdx][i + 3]);
                }
            }
        }
        fba.reset();
    }
    var it = map.iterator();
    var max: u64 = 0;
    while (it.next()) |entry|
    {
        if (entry.value_ptr.* > max)
        {
            max = entry.value_ptr.*;
        }
    }
    for (diffs) |row| gpa.free(row);
    for (prices) |row| gpa.free(row);
    try stdout.print("Part 2: {}\n", .{max});
}

pub fn main() !void
{
    const input = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(input);
    var ints = List(i32).init(gpa);
    defer ints.clearAndFree();
    for (input) |line|
    {
        try ints.append(try parseInt(i32, line, 10));
    }
    const t1 = std.time.milliTimestamp();
    try part1(ints.items);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(ints.items);
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
