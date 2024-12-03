const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");
const stdout = std.io.getStdOut().writer();

pub fn part1(left: []i32, right: []i32) !void {
    const lineCount: usize = left.len;
    sort(i32, left, {}, comptime std.sort.asc(i32));
    sort(i32, right, {}, comptime std.sort.asc(i32));
    var sum: i32 = 0;
    for (0..lineCount) |i| {
        const diff = right[i] - left[i];
        sum += if (diff < 0) -diff else diff;
    }
    try stdout.print("Part 1: {}\n", .{sum});
}

pub fn part2(left: []i32, right: []i32) !void {
    var sum: i64 = 0;
    for (left) |leftEl| {
        var instances: i8 = 0;
        for (right) |rightEl| {
            if (rightEl == leftEl) instances += 1;
        }
        sum += leftEl * instances;
    }
    try stdout.print("Part 2: {}\n", .{sum});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    const lines = try util.splitInputIntoLines(data);
    var left: []i32 = try std.heap.page_allocator.alloc(i32, 1000);
    var right: []i32 = try std.heap.page_allocator.alloc(i32, 1000);
    for (lines, 0..) |line, idx| {
        var splitLine = splitSeq(u8, line, "   ");
        if (splitLine.next()) |leftStr| {
            left[idx] = try parseInt(i32, leftStr, 10);
        }
        if (splitLine.next()) |rightStr| {
            right[idx] = try parseInt(i32, rightStr, 10);
        }
    }
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(left, right);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(left, right);
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
