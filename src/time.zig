const c = @import("root.zig").c;
const std = @import("std");

const time_segment_formatter = "{:0<2}";

pub fn avTimeToSeconds(duration: i64) i64 {
    return @divFloor(duration, c.AV_TIME_BASE);
}

pub fn avContextToSeconds(context: **c.AVFormatContext) i64 {
    return avTimeToSeconds(context.*.duration);
}

pub fn formatTime(allocator: std.mem.Allocator, seconds: i64) ![]const u8 {
    const hours: u64 = @intCast(@divFloor(seconds, 3_600));
    const minutes: u64 = @intCast(@divFloor(@mod(seconds, 3_600), 60));
    const secs: u64 = @intCast(@mod(seconds, 60));

    if (hours > 0) {
        return std.fmt.allocPrint(
            allocator,
            time_segment_formatter ++ ":" ++ time_segment_formatter ++ ":" ++ time_segment_formatter,
            .{ hours, minutes, secs },
        );
    } else {
        return std.fmt.allocPrint(
            allocator,
            time_segment_formatter ++ ":" ++ time_segment_formatter,
            .{ minutes, secs },
        );
    }
}

/// Should be free'd after use
pub fn avTimeToString(allocator: std.mem.Allocator, duration: i64) ![]const u8 {
    return formatTime(allocator, avTimeToSeconds(duration));
}

/// Should be free'd after use
pub fn avTimeContextToString(allocator: std.mem.Allocator, context: **c.AVFormatContext) ![]const u8 {
    return formatTime(allocator, avContextToSeconds(context));
}
