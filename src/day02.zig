const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day02.txt");
const stdout = std.io.getStdOut().writer();

pub fn good(arr: []i8) bool {
    var lastNum = arr[0];
    var increasing: ?bool = null;
    for (arr[1..]) |num| {
        if (num - lastNum < -3 or num - lastNum > 3 or num == lastNum) {
            return false;
        }
        if (increasing == null) {
            increasing = num - lastNum > 0;
        } else {
            if ((num - lastNum > 0) != increasing) {
                return false;
            }
        }
        lastNum = num;
    }
    return true;
}

pub fn part1() !void {
    const lines = try util.splitInputIntoLines(data);
    defer std.heap.page_allocator.free(lines);
    var safeCount: i16 = 0;
    for (lines) |line| {
        const numArr = try util.splitScaToNum(u8, i8, line, ' ');
        defer std.heap.page_allocator.free(numArr);
        if (good(numArr)) safeCount += 1;
    }
    try stdout.print("Part 1: {}\n", .{safeCount});
}

pub fn part2() !void {
    var lines = splitSca(u8, data, '\n');
    var safeCount: i16 = 0;
    while (lines.next()) |line| {
        const numArr = try util.splitScaToNum(u8, i8, line, ' ');
        defer std.heap.page_allocator.free(numArr);
        if (good(numArr)) {
            safeCount += 1;
            continue;
        }
        var numArrClone = try std.heap.page_allocator.alloc(i8, numArr.len - 1);
        defer std.heap.page_allocator.free(numArrClone);
        for (0..numArr.len) |i| {
            for (0..i) |j| { numArrClone[j] = numArr[j]; }
            for (i..(numArr.len - 1)) |j| { numArrClone[j] = numArr[j + 1]; }
            if (good(numArrClone)) {
                safeCount += 1;
                break;
            }
        }
    }
    try stdout.print("Part 2: {}\n", .{safeCount});
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
