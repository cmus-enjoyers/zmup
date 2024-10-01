const c = @import("root.zig").c;
const std = @import("std");

pub inline fn avTimeToSeconds(context: **c.AVFormatContext) i64 {
    return @divFloor(context.*.duration, c.AV_TIME_BASE);
}

/// Should be free'd after use
pub fn avTimeToString(allocator: std.mem.Allocator, context: **c.AVFormatContext) ![]const u8 {
    const total_seconds = avTimeToSeconds(context);

    const str = try std.fmt.allocPrint(allocator, "{:0>3}:{:0>3}", .{
        @divTrunc(total_seconds, 60),
        @mod(total_seconds, 60),
    });
    defer allocator.free(str);

    const x: []u8 = try allocator.dupe(u8, str);

    _ = std.mem.replace(u8, str, "+", "", x);

    return x[0..5];
}
