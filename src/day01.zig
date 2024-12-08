const std = @import("std");

const tokenizeAny = std.mem.tokenizeAny;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
const sort = std.mem.sort;

const data = @embedFile("data/day01.txt");
const test_data = @embedFile("data/day01_test.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var left_list = ArrayList(i32).init(allocator);
    defer left_list.deinit();
    var right_list = ArrayList(i32).init(allocator);
    defer right_list.deinit();

    try readListsSorted(&left_list, &right_list, data);

    var diffs = ArrayList(u32).init(allocator);
    defer diffs.deinit();
    try computeDiffs(left_list.items, right_list.items, &diffs);

    var diff_sum: u32 = 0;
    for (diffs.items) |diff| {
        diff_sum += diff;
    }

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Diff Sum: {}\n", .{diff_sum});
}

pub fn readListsSorted(left_list: *ArrayList(i32), right_list: *ArrayList(i32), buffer: []const u8) !void {
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

    sort(i32, left_list.items, {}, comptime std.sort.asc(i32));
    sort(i32, right_list.items, {}, comptime std.sort.asc(i32));
}

fn computeDiffs(left: []i32, right: []i32, diffs: *ArrayList(u32)) !void {
    for (left, right) |l, r| {
        try diffs.append(@abs(l - r));
    }
}

test "day 01" {
    var left = ArrayList(i32).init(std.testing.allocator);
    defer left.deinit();
    var right = ArrayList(i32).init(std.testing.allocator);
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

    var diffs = ArrayList(u32).init(std.testing.allocator);
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
