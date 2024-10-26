const std = @import("std");

pub fn setTimeout(time_ms: u64, last_keybind: *[]const u8) void {
    std.time.sleep(time_ms);
    last_keybind.* = "";
}
