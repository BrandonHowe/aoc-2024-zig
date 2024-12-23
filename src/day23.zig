const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day23.txt");
const stdout = std.io.getStdOut().writer();

const Pairing = struct
{
    left: u16,
    right: u16
};

const Triple = struct
{
    a: u16,
    b: u16,
    c: u16
};

fn displayU16(value: u16) [2]u8
{
    return [2]u8{ @as(u8, @intCast(value >> 8)), @as(u8, @intCast(value & ((1 << 8) - 1))) };
}

fn printPairing(pairing: Pairing) !void
{
    const v1: [2]u8 = [2]u8{ @as(u8, @intCast(pairing.left >> 8)), @as(u8, @intCast(pairing.left & ((1 << 8) - 1))) };
    const v2: [2]u8 = [2]u8{ @as(u8, @intCast(pairing.right >> 8)), @as(u8, @intCast(pairing.right & ((1 << 8) - 1))) };
    try stdout.print("{s}-{s}: {}-{}\n", .{v1, v2, pairing.left, pairing.right});
}

fn printTriple(triple: Triple) !void
{
    const v1: [2]u8 = [2]u8{ @as(u8, @intCast(triple.a >> 8)), @as(u8, @intCast(triple.a & ((1 << 8) - 1))) };
    const v2: [2]u8 = [2]u8{ @as(u8, @intCast(triple.b >> 8)), @as(u8, @intCast(triple.b & ((1 << 8) - 1))) };
    const v3: [2]u8 = [2]u8{ @as(u8, @intCast(triple.c >> 8)), @as(u8, @intCast(triple.c & ((1 << 8) - 1))) };
    try stdout.print("{s}-{s}-{s}\n", .{v1, v2, v3});
}

fn array_contains(haystack: []u16, needle: u16) bool
{
    for (haystack) |element| if (element == needle) return true; return false;
}

pub fn part1(graph: Map(u16, List(u16))) !void
{
    var connections = List(Triple).init(gpa);
    defer connections.clearAndFree();
    var it = graph.iterator();
    while (it.next()) |entry|
    {
        const c1 = entry.key_ptr.*;
        const c1Connected = entry.value_ptr.*.items;
        for (c1Connected) |c2|
        {
            if (graph.get(c2)) |c2Connected|
            {
                c1ConnectedLoop: for (c2Connected.items) |c3|
                {
                    if (array_contains(c1Connected, c3))
                    {
                        const found: bool = for (connections.items) |connection|
                        {
                            if (connection.a == c1 and connection.b == c2 and connection.c == c3) break true;
                            if (connection.a == c2 and connection.b == c1 and connection.c == c3) break true;
                            if (connection.a == c1 and connection.b == c3 and connection.c == c2) break true;
                            if (connection.a == c3 and connection.b == c2 and connection.c == c1) break true;
                            if (connection.a == c2 and connection.b == c3 and connection.c == c1) break true;
                            if (connection.a == c3 and connection.b == c1 and connection.c == c2) break true;
                        } else false;
                        if (!found) try connections.append(Triple{ .a = c1, .b = c2, .c = c3 });
                        continue :c1ConnectedLoop;
                    }
                }
            }
        }
    }

    var total: u64 = 0;
    for (connections.items) |item|
    {
        if (item.a >> 8 == 't' or item.b >> 8 == 't' or item.c >> 8 == 't') total += 1;
    }
    try stdout.print("Part 1: {any}\n", .{total});
}

pub fn part2(graph: Map(u16, List(u16))) !void
{
    var nodes = try gpa.alloc(u16, graph.count());
    {
        var it = graph.keyIterator();
        var i: usize = 0;
        while (it.next()) |item| : (i += 1)
        {
            nodes[i] = item.*;
        }
        sort(u16, nodes, {}, comptime asc(u16));
    }

    const threshold = 10;
    var common1 = List(u16).init(gpa);
    defer common1.clearAndFree();
    for (nodes) |n1|
    {
        for (nodes) |n2|
        {
            if (n1 == n2) continue;

            const c1 = graph.get(n1).?;
            const c2 = graph.get(n2).?;
            var commonCount: u8 = 0;
            for (c1.items) |c3|
            {
                if (array_contains(c2.items, c3))
                {
                    commonCount += 1;
                    try common1.append(c3);
                }
            }
            if (commonCount > threshold)
            {
                const valid = for (common1.items) |n3|
                {
                    if (n3 == n2) continue;
                    const c3 = graph.get(n3).?;
                    var commonCount2: u8 = 0;
                    for (c3.items) |n4|
                    {
                        if (array_contains(c2.items, n4)) commonCount2 += 1;
                    }
                    if (commonCount2 <= threshold) break false;
                } else true;
                if (valid)
                {
                    try common1.append(n1);
                    try common1.append(n2);
                    sort(u16, common1.items, {}, comptime asc(u16));
                    try stdout.print("Part 2: ", .{});
                    for (common1.items, 0..) |v, i|
                    {
                        if (i > 0) try stdout.print(",", .{});
                        try stdout.print("{s}", .{displayU16(v)});
                    }
                    try stdout.print("\n", .{});
                    return;
                }
            }

            common1.clearRetainingCapacity();
        }
    }
}

pub fn main() !void
{
    const lines = try util.splitInputIntoLines(data, gpa);
    defer gpa.free(lines);
    var pairings = try gpa.alloc(Pairing, lines.len);
    defer gpa.free(pairings);
    for (lines, 0..) |line, i|
    {
        const pairing = Pairing{ .left = @as(u16, line[0]) << 8 | line[1], .right = @as(u16, line[3]) << 8 | line[4] };
        pairings[i] = pairing;
    }

    var map = Map(u16, List(u16)).init(gpa);
    defer map.clearAndFree();
    for (pairings) |pairing|
    {
        var leftList = try map.getOrPutValue(pairing.left, List(u16).init(gpa));
        try leftList.value_ptr.append(pairing.right);
        var rightList = try map.getOrPutValue(pairing.right, List(u16).init(gpa));
        try rightList.value_ptr.append(pairing.left);
    }

    const t1 = std.time.milliTimestamp();
    try part1(map);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(map);
    const t3 = std.time.milliTimestamp();
    try stdout.print("Part 2: {}ms\n", .{t3 - t2});

    var vit = map.valueIterator();
    while (vit.next()) |value|
    {
        value.*.clearAndFree();
    }
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
