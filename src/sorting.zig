const std = @import("std");
const playlists = @import("playlists.zig");

const Data = struct { data: u8 };

pub fn sort(list: std.ArrayList(*playlists.Playlist)) !void {
    const sorted_list = std.mem.sort(*playlists.Playlist, list.items[0..], {}, lessThan);

    std.debug.print("{any}\n", .{sorted_list});
}

fn lessThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}
