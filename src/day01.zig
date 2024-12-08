const std = @import("std");
const Allocator = std.mem.Allocator;
const List = std.ArrayList;
const Map = std.AutoHashMap;
const StrMap = std.StringHashMap;
const BitSet = std.DynamicBitSet;

const util = @import("util.zig");
const gpa = util.gpa;

const data = @embedFile("data/day01.txt");
const test_data = @embedFile("data/day01_test.txt");

pub fn main() !void {
    var left_list = List(i32).init(std.heap.page_allocator);
    defer left_list.deinit();
    var right_list = List(i32).init(std.heap.page_allocator);
    defer right_list.deinit();

    try readListsSorted(&left_list, &right_list, data);

    var diffs = List(u32).init(std.heap.page_allocator);
    defer diffs.deinit();
    try computeDiffs(left_list.items, right_list.items, &diffs);

    var diff_sum: u32 = 0;
    for (diffs.items) |diff| {
        diff_sum += diff;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Diff Sum: {}\n", .{diff_sum});
}

pub fn readListsSorted(left_list: *List(i32), right_list: *List(i32), buffer: []const u8) !void {
    var line_iterator = tokenizeAny(u8, buffer, "\n");
    while (line_iterator.next()) |line| {
        var word_iterator = tokenizeAny(u8, line, " ");
        var index: u8 = 0;
        while (word_iterator.next()) |word| : (index += 1) {
            const is_left = index == 0;
            const is_right = index == 1;
            assert(is_left or is_right);
            const num = try parseInt(i32, word, 10);
            if (is_left) {
                try left_list.append(num);
            } else {
                try right_list.append(num);
            }
        }
    }

    std.mem.sort(i32, left_list.items, {}, comptime std.sort.asc(i32));
    std.mem.sort(i32, right_list.items, {}, comptime std.sort.asc(i32));
}

fn computeDiffs(left: []i32, right: []i32, diffs: *List(u32)) !void {
    for (left, right) |l, r| {
        try diffs.append(@abs(l - r));
    }
}

test "day 01" {
    var left = List(i32).init(std.testing.allocator);
    defer left.deinit();
    var right = List(i32).init(std.testing.allocator);
    defer right.deinit();

    try readListsSorted(&left, &right, test_data);

    const left_ex = [_]i32{ 1, 2, 3, 3, 3, 4 };
    const right_ex = [_]i32{ 3, 3, 3, 4, 5, 9 };
    for (left_ex, left.items) |e, a| {
        try std.testing.expectEqual(e, a);
    }
    for (right_ex, right.items) |e, a| {
        try std.testing.expectEqual(e, a);
    }

    var diffs = List(u32).init(std.testing.allocator);
    defer diffs.deinit();
    try computeDiffs(left.items, right.items, &diffs);
    const diffs_ex = [_]u32{ 2, 1, 0, 1, 2, 5 };
    for (diffs_ex, diffs.items) |ex, act| {
        try std.testing.expectEqual(ex, act);
    }

    var diff_sum: u32 = 0;
    for (diffs.items) |diff| {
        diff_sum += diff;
    }
    try std.testing.expectEqual(11, diff_sum);
}

// Useful stdlib functions=
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
