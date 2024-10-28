const std = @import("std");
const playlists = @import("../playlists/playlists.zig");
const sorting = @import("../playlists/sorting.zig");
const vaxis = @import("vaxis");

pub fn input(key: vaxis.Key, last_keybind: *[]const u8, music: *const std.ArrayList(*playlists.Playlist)) !void {
    if (key.matches('j', .{}) and std.mem.eql(u8, last_keybind.*, "s")) {
        try sorting.sort(music, sorting.SortMethods.greater);
        last_keybind.* = "";
    }

    if (key.matches('k', .{}) and std.mem.eql(u8, last_keybind.*, "s")) {
        try sorting.sort(music, sorting.SortMethods.less);
        last_keybind.* = "";
    }
}
