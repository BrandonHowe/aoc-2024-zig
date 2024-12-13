const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day13.txt");
const stdout = std.io.getStdOut().writer();

const Machine = struct
{
    x1: u16,
    y1: u16,
    x2: u16,
    y2: u16,
    prizeX: u64,
    prizeY: u64
};

pub fn solve(machines: List(Machine), offset: u64) u64
{

    var total: u64 = 0;
    for (machines.items) |machine|
    {
        const det: f64 = @floatFromInt(@as(i32, machine.x1 * machine.y2) - @as(i32, machine.x2 * machine.y1));
        const m1: f64 = @as(f64, @floatFromInt(machine.y2));
        const m2: f64 = -@as(f64, @floatFromInt(machine.x2));
        const m3: f64 = -@as(f64, @floatFromInt(machine.y1));
        const m4: f64 = @as(f64, @floatFromInt(machine.x1));

        var v1 = m1 * @as(f64, @floatFromInt(offset + machine.prizeX)) + m2 * @as(f64, @floatFromInt(offset + machine.prizeY));
        var v2 = m3 * @as(f64, @floatFromInt(offset + machine.prizeX)) + m4 * @as(f64, @floatFromInt(offset + machine.prizeY));
        v1 /= det;
        v2 /= det;

        if (v1 == std.math.ceil(v1) and v2 == std.math.ceil(v2)) {
            total += @as(u64, @intFromFloat(v1)) * 3 + @as(u64, @intFromFloat(v2));
        }
    }
    return total;
}

pub fn part1(machines: List(Machine)) !void
{
    const total = solve(machines, 0);
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(machines: List(Machine)) !void
{
    const total = solve(machines, 10000000000000);
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    const t0 = std.time.milliTimestamp();
    const lines = try util.splitInputIntoLines(data, gpa);
    var machines: List(Machine) = List(Machine).init(gpa);
    for (0..(lines.len / 4)) |i|
    {
        const line1 = lines[i * 4];
        const x1 = try parseInt(u16, line1[12..14], 10);
        const y1 = try parseInt(u16, line1[18..20], 10);

        const line2 = lines[i * 4 + 1];
        const x2 = try parseInt(u16, line2[12..14], 10);
        const y2 = try parseInt(u16, line2[18..20], 10);

        var splitLine3 = splitSca(u8, lines[i * 4 + 2], ',');
        const prizeX = try parseInt(u64, splitLine3.next().?[9..], 10);
        const prizeY = try parseInt(u64, splitLine3.next().?[3..], 10);
        try machines.append(Machine{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2, .prizeX = prizeX, .prizeY = prizeY });
    }
    const t1 = std.time.milliTimestamp();
    try stdout.print("Parsing: {}ms\n", .{t1 - t0});
    try part1(machines);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(machines);
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
