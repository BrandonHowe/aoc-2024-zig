const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day07.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1() !void
{
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();
    var lines = splitSca(u8, data, '\n');
    var total: i64 = 0;
    lines: while (lines.next()) |line|
    {
        var splitLine = splitSeq(u8, line, ": ");
        const target = try parseInt(i64, splitLine.next() orelse "", 10);
        const nums = try util.splitScaToNum(u8, i64, splitLine.next() orelse "", ' ', allocator);
        const opCount = nums.len - 1;
        op: for (0..@intCast(std.math.shl(u16, 1, opCount))) |ops|
        {
            var computed: i64 = nums[0];
            for (0..opCount) |i|
            {
                if ((ops & @as(usize, std.math.shl(u16, 1, i))) == 0)
                {
                    computed += nums[i + 1];
                }
                else
                {
                    computed *= nums[i + 1];
                }
                if (computed > target) continue :op;
            }
            if (computed == target)
            {
                total += target;
                continue :lines;
            }
        }
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2() !void
{
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    const allocator = arena.allocator();
    var lines = splitSca(u8, data, '\n');
    var total: i64 = 0;
    lines: while (lines.next()) |line|
    {
        var splitLine = splitSeq(u8, line, ": ");
        const target = try parseInt(i64, splitLine.next() orelse "", 10);
        const nums = try util.splitScaToNum(u8, i64, splitLine.next() orelse "", ' ', allocator);
        const opCount = nums.len - 1;
        op: for (0..@intCast(std.math.pow(u32, 3, @intCast(opCount)))) |ops|
        {
            var computed: i64 = nums[0];
            for (0..opCount) |i|
            {
                const state = (ops / std.math.pow(u32, 3, @intCast(i))) % 3;
                if (state == 0)
                {
                    computed += nums[i + 1];
                }
                else if (state == 1)
                {
                    computed *= nums[i + 1];
                }
                else if (state == 2)
                {
                    const digits = std.math.log10(@abs(nums[i + 1])) + 1;
                    computed *= std.math.pow(i64, 10, @intCast(digits));
                    computed += nums[i + 1];
                }
                if (computed > target) continue :op;
            }
            if (computed == target)
            {
                total += target;
                continue :lines;
            }
        }
    }
    try stdout.print("Part 2: {}\n", .{total});
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
