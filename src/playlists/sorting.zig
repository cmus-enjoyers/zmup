const std = @import("std");
const playlists = @import("playlists.zig");

pub const SortMethods = enum {
    less,
    greater,
};

pub fn sort(list: *const std.ArrayList(*playlists.Playlist), sort_type: SortMethods) !void {
    const list_items = list.items[0..];

    switch (sort_type) {
        .less => sortPlaylist(list_items, lessThan),
        .greater => sortPlaylist(list_items, greaterThan),
    }
}

fn sortPlaylist(items: []*playlists.Playlist, sort_method: fn (_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool) void {
    std.mem.sort(*playlists.Playlist, items, {}, sort_method);
}

fn lessThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn greaterThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .gt;
}
