const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day19.txt");
const stdout = std.io.getStdOut().writer();

const Towel = struct
{
    val: u256,
    len: u8
};

pub fn getLastBits(number: u256, n: u8) u256 {
    const mask = @shlExact(@as(u256,1), n) - 1;
    return number & mask;
}

pub fn part1(towels: []Towel, designs: []Towel) !void
{
    var total: u32 = 0;
    var current = List(Towel).init(gpa);
    defer current.clearAndFree();
    var next = Map(Towel, bool).init(gpa);
    defer next.clearAndFree();
    for (designs) |design|
    {
        current.clearRetainingCapacity();
        next.clearRetainingCapacity();
        for (towels) |t|
        {
            if (t.val == getLastBits(design.val, t.len * 3)) try current.append(t);
        }
        const found = search: while (true)
        {
            if (current.items.len == 0) break false;
            for (current.items) |currentItem|
            {
                if (currentItem.val == design.val) break :search true;
                const shiftedDesign = design.val >> (currentItem.len * 3);
                for (towels) |towel|
                {
                    if ((shiftedDesign & towel.val) == towel.val)
                    {
                        const newItem: u256 = (towel.val << (currentItem.len * 3)) | currentItem.val;
                        const newTowel: Towel = Towel{ .val = newItem, .len = towel.len + currentItem.len };
                        if (newItem == getLastBits(design.val, newTowel.len * 3))
                        {
                            try next.put(newTowel, true);
                        }
                    }
                }
            }
            current.clearRetainingCapacity();
            var it = next.keyIterator();
            while (it.next()) |item| try current.append(item.*);
            next.clearRetainingCapacity();
        };
        if (found) total += 1;
    }
    try stdout.print("Part 1: {}\n", .{total});
}

pub fn part2(towels: []Towel, designs: []Towel) !void
{
    var total: u64 = 0;
    var current = Map(Towel, u64).init(gpa);
    defer current.clearAndFree();
    var next = Map(Towel, u64).init(gpa);
    defer next.clearAndFree();
    for (designs) |design|
    {
        current.clearRetainingCapacity();
        next.clearRetainingCapacity();
        for (towels) |t|
        {
            if (t.val == getLastBits(design.val, t.len * 3)) try current.put(t, 1);
        }
        var ways: u64 = 0;
        while (current.count() > 0)
        {
            var it = current.iterator();
            while (it.next()) |entry|
            {
                const currentItem = entry.key_ptr.*;
                const amount = entry.value_ptr.*;
                if (currentItem.val == design.val)
                {
                    ways += amount;
                    continue;
                }
                if (currentItem.len > design.len) continue;
                const shiftedDesign = design.val >> (currentItem.len * 3);
                for (towels) |towel|
                {
                    if ((shiftedDesign & towel.val) == towel.val)
                    {
                        const newItem: u256 = (towel.val << (currentItem.len * 3)) | currentItem.val;
                        const newTowel: Towel = Towel{ .val = newItem, .len = towel.len + currentItem.len };
                        if (newItem == getLastBits(design.val, newTowel.len * 3))
                        {
                            if (next.get(newTowel)) |v|
                            {
                                try next.put(newTowel, v + amount);
                            }
                            else
                            {
                                try next.put(newTowel, amount);
                            }
                        }
                    }
                }
            }
            current.clearRetainingCapacity();
            it = next.iterator();
            while (it.next()) |item| try current.put(item.key_ptr.*, item.value_ptr.*);
            next.clearRetainingCapacity();
        }
        total += ways;
    }
    try stdout.print("Part 2: {}\n", .{total});
}

pub fn main() !void
{
    var it = splitSeq(u8, data, "\n\n");
    const towelStr = it.next().?;
    var towelIt = splitSeq(u8, towelStr, ", ");
    var towels = List(Towel).init(gpa);
    defer towels.clearAndFree();
    while (towelIt.next()) |str|
    {
        var towel = Towel{ .len = 0, .val = 0 };
        for (str) |char|
        {
            towel.val = towel.val << 3;
            towel.len += 1;
            if (char == 'w') towel.val = towel.val | 1;
            if (char == 'u') towel.val = towel.val | 2;
            if (char == 'b') towel.val = towel.val | 3;
            if (char == 'r') towel.val = towel.val | 4;
            if (char == 'g') towel.val = towel.val | 5;
        }
        try towels.append(towel);
    }
    var designIt = splitSca(u8, it.next().?, '\n');
    var designs = List(Towel).init(gpa);
    defer designs.clearAndFree();
    while (designIt.next()) |str|
    {
        var towel = Towel{ .len = 0, .val = 0 };
        for (str) |char|
        {
            towel.val = towel.val << 3;
            towel.len += 1;
            if (char == 'w') towel.val = towel.val | 1;
            if (char == 'u') towel.val = towel.val | 2;
            if (char == 'b') towel.val = towel.val | 3;
            if (char == 'r') towel.val = towel.val | 4;
            if (char == 'g') towel.val = towel.val | 5;
        }
        try designs.append(towel);
    }
    const t1 = std.time.milliTimestamp();
    try part1(towels.items, designs.items);
    const t2 = std.time.milliTimestamp();
    try stdout.print("Part 1: {}ms\n", .{t2 - t1});
    try part2(towels.items, designs.items);
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
