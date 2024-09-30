const std = @import("std");
const playlists = @import("playlists.zig");

pub const SortMethods = enum {
    less,
    greater,
};

pub fn chooseSort(list: std.ArrayList(*playlists.Playlist), sortType: SortMethods) !void {
    const list_items = list.items[0..];
    try switch (sortType) {
        .less => sort(list_items, lessThan),
        .greater => sort(list_items, greaterThan),
    };
}

fn sort(items: []*playlists.Playlist, sortMethod: fn (_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool) !void {
    std.mem.sort(*playlists.Playlist, items, {}, sortMethod);
}

fn lessThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn greaterThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .gt;
}
