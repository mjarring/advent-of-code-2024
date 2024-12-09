const std = @import("std");

const data = @embedFile("data/day02.txt");
const test_data = @embedFile("data/day02_test.txt");

const Report = struct {
    levels: []u8,
    fn isSafe(self: *const Report) bool {
        return self.adjacentInRange() and (self.allAscending() or self.allDescending());
    }
    fn allAscending(self: *const Report) bool {
        std.debug.assert(self.levels.len >= 2);
        for (self.levels, 0..) |current, index| {
            if (index == self.levels.len - 1) break;
            const next = self.levels[index + 1];
            if (next <= current) return false;
        }
        return true;
    }
    fn allDescending(self: *const Report) bool {
        std.debug.assert(self.levels.len >= 2);
        for (self.levels, 0..) |current, index| {
            if (index == self.levels.len - 1) break;
            const next = self.levels[index + 1];
            if (next >= current) return false;
        }
        return true;
    }
    fn adjacentInRange(self: *const Report) bool {
        std.debug.assert(self.levels.len >= 2);
        for (self.levels, 0..) |current, index| {
            if (index == self.levels.len - 1) break;
            const next = self.levels[index + 1];
            const diff = if (current > next)
                current - next
            else
                next - current;
            if (diff < 1 or diff > 3) return false;
        }
        return true;
    }
};

fn readReports(buffer: []const u8, allocator: std.mem.Allocator) ![]Report {
    var reports = std.ArrayList(Report).init(allocator);
    defer reports.deinit();
    var report_it = std.mem.tokenizeAny(u8, buffer, "\n");
    while (report_it.next()) |report| {
        var level_it = std.mem.tokenizeAny(u8, report, " ");
        var levels = std.ArrayList(u8).init(allocator);
        defer levels.deinit();
        while (level_it.next()) |level| {
            const level_value = try std.fmt.parseInt(u8, level, 10);
            try levels.append(level_value);
        }
        const rep_struct = Report{ .levels = try levels.toOwnedSlice() };
        try reports.append(rep_struct);
    }
    return try reports.toOwnedSlice();
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    const reports = try readReports(data, allocator);
    defer {
        for (reports) |report| {
            allocator.free(report.levels);
        }
        allocator.free(reports);
    }

    var safe_reports: u32 = 0;
    for (reports) |report| {
        if (report.isSafe()) {
            safe_reports += 1;
        }
    }
    const stdout = std.io.getStdOut().writer();
    try stdout.print("Safe Reports: {}\n", .{safe_reports});
}

test "day 02" {
    const reports = try readReports(test_data, std.testing.allocator);
    defer {
        for (reports) |report| {
            std.testing.allocator.free(report.levels);
        }
        std.testing.allocator.free(reports);
    }
    try std.testing.expect(reports.len == 6);
    try std.testing.expectEqual(true, reports[0].isSafe());
    try std.testing.expectEqual(false, reports[0].allAscending());
    try std.testing.expectEqual(true, reports[0].allDescending());
    try std.testing.expectEqual(false, reports[1].isSafe());
    try std.testing.expectEqual(true, reports[1].allAscending());
    try std.testing.expectEqual(false, reports[1].allDescending());
    try std.testing.expectEqual(false, reports[2].isSafe());
    try std.testing.expectEqual(false, reports[2].allAscending());
    try std.testing.expectEqual(true, reports[2].allDescending());
    try std.testing.expectEqual(false, reports[3].isSafe());
    try std.testing.expectEqual(false, reports[3].allAscending());
    try std.testing.expectEqual(false, reports[3].allDescending());
    try std.testing.expectEqual(false, reports[4].isSafe());
    try std.testing.expectEqual(false, reports[4].allAscending());
    try std.testing.expectEqual(false, reports[4].allDescending());
    try std.testing.expectEqual(true, reports[5].isSafe());
    try std.testing.expectEqual(true, reports[5].allAscending());
    try std.testing.expectEqual(false, reports[5].allDescending());
}
