const std = @import("std");
const mach = @import("mach");

pub fn play_music(path: []const u8) void {
    _ = path;
    _ = mach.sysaudio.;
}
