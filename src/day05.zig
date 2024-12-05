const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day05.txt");
const stdout = std.io.getStdOut().writer();

const PageRule = struct {
    a: i16,
    b: i16
};

pub fn part1(rules: []PageRule, pageStrs: [][]const u8) !void
{
    var sum: i16 = 0;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    var allocator = arena.allocator();
    updates: for (pageStrs) |line|
    {
        const splitLine = try util.splitScaToNum(u8, i8, line, ',', allocator);
        defer allocator.free(splitLine);
        
        for (splitLine, 0..) |num1, i|
        {
            checker: for (splitLine, 0..) |num2, j|
            {
                if (i == j) continue;
                if (i < j)
                {
                    for (rules) |rule|
                    {
                        if (rule.a == num1 and rule.b == num2)
                        {
                            continue :checker;
                        }
                        if (rule.a == num2 and rule.b == num1)
                        {
                            continue :updates;
                        }
                    }
                }
            }
        }

        sum += splitLine[splitLine.len / 2];
    }
    try stdout.print("Part 1: {}\n", .{sum});
}

pub fn part2(rules: []PageRule, pageStrs: [][]const u8) !void
{
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    var allocator = arena.allocator();
    var sum: i16 = 0;
    for (pageStrs) |line|
    {
        // var tryAgain = true;
        // var failedOnce = false;
        const splitLine = try util.splitScaToNum(u8, i8, line, ',', allocator);
        defer allocator.free(splitLine);
        var indicators = try allocator.alloc(i8, splitLine.len);
        defer allocator.free(indicators);

        for (splitLine, 0..) |num1, i|
        {
            var lefts: i8 = 0;
            var rights: i8 = 0;
            for (splitLine, 0..) |num2, j|
            {
                if (i == j) continue;
                for (rules) |rule|
                {
                    if (rule.a == num1 and rule.b == num2)
                    {
                        lefts += 1;
                    }
                    if (rule.a == num2 and rule.b == num1)
                    {
                        rights += 1;
                    }
                }
            }
            indicators[i] = lefts - rights;
        }
        var sorted = true;
        var middleVal: i16 = 0;
        for (0..indicators.len) |i|
        {
            if (i > 0)
            {
                if (indicators[i] > indicators[i - 1])
                {
                    sorted = false;
                }
            }
            if (indicators[i] == 0)
            {
                middleVal = splitLine[i];
            }
        }
        if (!sorted)
        {
            sum += middleVal;
        }
    }
    try stdout.print("Part 2: {}\n", .{sum});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    const lines = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(lines);
    var idxOfBreak: usize = 0;
    for (lines, 0..) |line, idx|
    {
        if (line.len == 0)
        {
            idxOfBreak = idx;
            break;
        }
    }
    const ruleStrs = lines[0..idxOfBreak];
    const pageStrs = lines[(idxOfBreak + 1)..]
    ;
    var arena = std.heap.ArenaAllocator.init(gpa);
    defer arena.deinit();
    var allocator = arena.allocator();

    const rules = try allocator.alloc(PageRule, ruleStrs.len);
    defer allocator.free(rules);
    
    for (ruleStrs, 0..) |line, i|
    {
        const splitLine = try util.splitScaToNum(u8, i16, line, '|', allocator);
        defer allocator.free(splitLine);
        rules[i] = PageRule{ .a = splitLine[0], .b = splitLine[1]};
    }
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});

    try part1(rules, pageStrs);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});

    try part2(rules, pageStrs);
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
