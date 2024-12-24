const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day24.txt");
const stdout = std.io.getStdOut().writer();

const Instruction = struct{
    instr: u8,
    in1: u32,
    in2: u32,
    out: u32
};

fn charsToU32(chars: *const [3]u8) u32
{
    return (@as(u32, @intCast(chars[0])) << 16) | (@as(u32, @intCast(chars[1])) << 8) | chars[2];
}

fn u32ToChars(v: u32) [3]u8
{
    return [3]u8 { @as(u8, @intCast(v >> 16)), @as(u8, @intCast((v >> 8) & ((1 << 8) - 1))), @as(u8, @intCast((v & ((1 << 8) - 1)))) };
}

fn valueOf(target: u32, startingState: Map(u32, u8), instructions: Map(u32, Instruction)) u32
{
    if (startingState.get(target)) |startingVal|
    {
        return startingVal;
    }
    else
    {
        const instruction = instructions.get(target) orelse unreachable;
        const v1 = valueOf(instruction.in1, startingState, instructions);
        const v2 = valueOf(instruction.in2, startingState, instructions);
        if (instruction.instr == 1) return v1 & v2;
        if (instruction.instr == 2) return v1 ^ v2;
        if (instruction.instr == 3) return v1 | v2;
        unreachable;
    }
}

pub fn part1Impl(startingState: Map(u32, u8), instructions: Map(u32, Instruction)) !u64
{
    const z00 = charsToU32("z00");
    var total: u64 = 0;

    var it = instructions.keyIterator();
    while (it.next()) |l|
    {
        const key = l.*;
        const value: u64 = valueOf(key, startingState, instructions);
        if (key >= z00)
        {
            const diff = try parseInt(u8, u32ToChars(key)[1..], 10);
            total = total | (value << @as(u6, @intCast(diff)));
        }
    }

    return total;
}

pub fn part1(startingState: Map(u32, u8), instructions: Map(u32, Instruction)) !void
{
    const output = try part1Impl(startingState, instructions);
    try stdout.print("Part 1: {}\n", .{output});
}

pub fn part2(startingState: Map(u32, u8), instructions: Map(u32, Instruction)) !void
{
    var it = startingState.iterator();
    var xVal: u64 = 0;
    var yVal: u64 = 0;
    while (it.next()) |entry|
    {
        const key = entry.key_ptr.*;
        const val = @as(u64, entry.value_ptr.*);
        const str = u32ToChars(key);
        const offset = try parseInt(u8, str[1..], 10);
        if (str[0] == 'x')
        {
            xVal = xVal | (val << @as(u6, @intCast(offset)));
        }
        else if (str[0] == 'y')
        {
            yVal = yVal | (val << @as(u6, @intCast(offset)));
        }
    }
    const output = try part1Impl(startingState, instructions);
    try stdout.print("Part 2 performed manually on input. Error: {}\n", .{(xVal + yVal) ^ output});
}

pub fn main() !void
{
    var splitData = splitSeq(u8, data, "\n\n");
    var state = Map(u32, u8).init(gpa);
    defer state.clearAndFree();
    var instrs = Map(u32, Instruction).init(gpa);
    defer instrs.clearAndFree();
    {
        const d1 = splitData.next().?;
        const lines = try util.splitInputIntoLines(d1, gpa);
        defer gpa.free(lines);
        for (lines) |line|
        {
            const key = charsToU32(line[0..3]);
            const val = line[5] - '0';
            try state.put(key, val);
        }
    }
    {
        const d2 = splitData.next().?;
        const lines = try util.splitInputIntoLines(d2, gpa);
        defer gpa.free(lines);
        for (lines) |line|
        {
            const instr: u8 = if (line[4] == 'A') 1 else if (line[4] == 'X') 2 else 3;
            if (instr != 3)
            {
                const out = charsToU32(line[15..18]);
                const inst = Instruction{
                    .instr = instr,
                    .in1 = charsToU32(line[0..3]),
                    .in2 = charsToU32(line[8..11]),
                    .out = out
                };
                try instrs.put(out, inst);
            }
            else
            {
                const out = charsToU32(line[14..17]);
                const inst = Instruction{
                    .instr = instr,
                    .in1 = charsToU32(line[0..3]),
                    .in2 = charsToU32(line[7..10]),
                    .out = out
                };
                try instrs.put(out, inst);
            }
        }
    }

    const t1 = std.time.milliTimestamp();
    try part1(state, instrs);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(state, instrs);
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
