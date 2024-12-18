const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day17.txt");
const stdout = std.io.getStdOut().writer();

const Program = struct
{
    registerA: u64,
    registerB: u64,
    registerC: u64,
    program: []u8,
    instrPtr: usize
};

pub fn runProgram(registerA: u128, allocator: Allocator) ![]u8
{
    var outputs = List(u8).init(allocator);
    defer outputs.clearAndFree();

    var a = registerA;
    while (a > 0)
    {
        var b = a % 8;
        b = b ^ 3;
        const c = a / @shlExact(@as(u64, 1), @as(u5, @intCast(b)));
        b = b ^ 5;
        a = a / 8;
        b = b ^ c;
        try outputs.append(@as(u8, @intCast(b % 8)));
    }

    return outputs.toOwnedSlice();
}

pub fn part1(programBase: Program) !void
{
    const output = try runProgram(programBase.registerA, gpa);
    defer gpa.free(output);
    try stdout.print("Part 1: {any}\n", .{output});
}

pub fn part2(programBase: Program) !void
{
    const buffer = try gpa.alloc(u8, 1000);
    defer gpa.free(buffer);
    var fba = std.heap.FixedBufferAllocator.init(buffer);
    const allocator = fba.allocator();
    // _ = allocator;
    const program = programBase.program;

    var matchedDigits: u8 = 0;
    var base: u128 = 0;

    while (matchedDigits < program.len)
    {
        var tempBase: u128 = 0;
        for (1..100000000) |rawI|
        {
            const log8: u7 = @as(u7, @intCast(std.math.log2(rawI) / 3)) + 1;
            const b1 = @shlExact(base, log8 * 3);
            const i = b1 + rawI;
            const res = try runProgram(i, allocator);
            var matches: u8 = 0;
            for (0..res.len) |j|
            {
                if (j >= program.len) break;
                if (res[res.len - j - 1] == program[program.len - j - 1]) { matches += 1; }
                else break;
            }
            if (matches > matchedDigits + 6 or matches >= program.len)
            {
                tempBase = i;
                break;
            }
            fba.reset();
        }
        while (tempBase >= @shlExact(@as(u128, 1), @as(u7, @intCast((matchedDigits + 5) * 3))))
        {
            tempBase /= 8;
        }
        matchedDigits += 5;
        base = tempBase;
    }

    try stdout.print("Part 2: {}\n", .{base});
}

pub fn main() !void
{
    var program = Program{ .registerA = 0, .registerB = 0, .registerC = 0, .program = std.mem.zeroes([]u8), .instrPtr = 0 };
    var lines = splitSca(u8, data, '\n');
    if (lines.next()) |regALine|
    {
        program.registerA = try parseInt(u64, regALine[12..], 10);
    }
    if (lines.next()) |regBLine|
    {
        program.registerB = try parseInt(u64, regBLine[12..], 10);
    }
    if (lines.next()) |regCLine|
    {
        program.registerC = try parseInt(u64, regCLine[12..], 10);
    }
    _ = lines.next();
    if (lines.next()) |programLine|
    {
        const content = programLine[9..];
        const nums = try util.splitScaToNum(u8, u8, content, ',', gpa);
        program.program = nums;
    }
    const t1 = std.time.milliTimestamp();
    try part1(program);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(program);
    const t3 = std.time.milliTimestamp();
    try stdout.print("Part 2: {}ms\n", .{t3 - t2});
    gpa.free(program.program);
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
