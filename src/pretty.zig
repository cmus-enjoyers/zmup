const c = @import("root.zig").c;
const std = @import("std");

pub fn avTimeToSeconds(context: **c.AVFormatContext) i64 {
    return @divFloor(context.*.duration, c.AV_TIME_BASE);
}
