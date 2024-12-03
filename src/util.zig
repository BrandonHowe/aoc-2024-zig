const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;
const Str = []const u8;

var gpa_impl = std.heap.GeneralPurposeAllocator(.{}){};
pub const gpa = gpa_impl.allocator();

// Add utility functions here

pub fn createArrayFromSplitIteratorU8(it: *std.mem.SplitIterator(u8, std.mem.DelimiterType.scalar)) ![][]const u8 {
    var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer list.deinit();

    while (it.next()) |item| {
        try list.append(item);
    }

    return list.toOwnedSlice();
}

pub fn splitInputIntoLines(data: []const u8) ![][]const u8 {
    var linesIt = splitSca(u8, data, '\n');
    var list = std.ArrayList([]const u8).init(std.heap.page_allocator);
    defer list.deinit();

    while (linesIt.next()) |item| {
        try list.append(item);
    }

    return list.toOwnedSlice();
}

pub fn splitScaToNum(T: type, U: type, buffer: []const T, delimiter: T) ![]U {
    var it = splitSca(T, buffer, delimiter);
    var list = std.ArrayList(U).init(std.heap.page_allocator);
    defer list.deinit();

    while (it.next()) |item| {
        try list.append(try parseInt(U, item, 10));
    }

    return list.toOwnedSlice();
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