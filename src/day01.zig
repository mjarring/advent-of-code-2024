const std = @import("std");

const tokenizeAny = std.mem.tokenizeAny;
const ArrayList = std.ArrayList;
const assert = std.debug.assert;
const parseInt = std.fmt.parseInt;
const sort = std.mem.sort;
const AutoHashMap = std.AutoHashMap;

const data = @embedFile("data/day01.txt");
const test_data = @embedFile("data/day01_test.txt");

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var left = ArrayList(u32).init(allocator);
    defer left.deinit();
    var right = ArrayList(u32).init(allocator);
    defer right.deinit();

    try readListsSorted(&left, &right, data);

    const diff_sum = try computeDiff(left.items, right.items);
    const similarity = try computeSimilarity(left.items, right.items, allocator);

    const stdout = std.io.getStdOut().writer();
    try stdout.print("Diff Sum: {}\n", .{diff_sum});
    try stdout.print("Similarity: {}\n", .{similarity});
}

fn readListsSorted(left_list: *ArrayList(u32), right_list: *ArrayList(u32), buffer: []const u8) !void {
    var line_iterator = tokenizeAny(u8, buffer, "\n");
    while (line_iterator.next()) |line| {
        var word_iterator = tokenizeAny(u8, line, " ");
        var index: u8 = 0;
        while (word_iterator.next()) |word| : (index += 1) {
            const is_left = index == 0;
            const is_right = index == 1;
            assert(is_left or is_right);
            const num = try parseInt(u32, word, 10);
            if (is_left) {
                try left_list.append(num);
            } else {
                try right_list.append(num);
            }
        }
    }

    sort(u32, left_list.items, {}, comptime std.sort.asc(u32));
    sort(u32, right_list.items, {}, comptime std.sort.asc(u32));
}

fn computeDiff(left: []u32, right: []u32) !u64 {
    var sum: u64 = 0;
    for (left, right) |l, r| {
        if (l > r) {
            sum += l - r;
        } else {
            sum += r - l;
        }
    }
    return sum;
}

fn computeSimilarity(left: []u32, right: []u32, allocator: std.mem.Allocator) !u32 {
    var map = AutoHashMap(u32, u32).init(allocator);
    defer map.deinit();

    for (right) |id| {
        const result = try map.getOrPut(id);
        if (result.found_existing) {
            result.value_ptr.* += 1;
        } else {
            result.value_ptr.* = 1;
        }
    }

    var sum: u32 = 0;
    for (left) |id| {
        if (map.get(id)) |value| {
            sum += id * value;
        }
    }

    return sum;
}

test "day 01" {
    var left = ArrayList(u32).init(std.testing.allocator);
    defer left.deinit();
    var right = ArrayList(u32).init(std.testing.allocator);
    defer right.deinit();

    try readListsSorted(&left, &right, test_data);

    const left_ex = [_]u32{ 1, 2, 3, 3, 3, 4 };
    const right_ex = [_]u32{ 3, 3, 3, 4, 5, 9 };
    for (left_ex, left.items) |e, a| {
        try std.testing.expectEqual(e, a);
    }
    for (right_ex, right.items) |e, a| {
        try std.testing.expectEqual(e, a);
    }

    const diff_sum = try computeDiff(left.items, right.items);
    try std.testing.expectEqual(11, diff_sum);

    const similarity = computeSimilarity(left.items, right.items, std.testing.allocator);
    try std.testing.expectEqual(31, similarity);
}
