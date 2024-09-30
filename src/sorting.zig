const std = @import("std");
const playlists = @import("playlists.zig");

pub const SortTypes = enum {
    less,
    greater,
};

pub fn sort(list: std.ArrayList(*playlists.Playlist), sortType: SortTypes) !void {
    const sorted_list = switch (sortType) {
        .less => std.mem.sort(*playlists.Playlist, list.items[0..], {}, lessThan),
        .greater => std.mem.sort(*playlists.Playlist, list.items[0..], {}, greaterThan),
    };

    std.debug.print("{any}\n", .{sorted_list});
}

fn lessThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .lt;
}

fn greaterThan(_: void, lhs: *playlists.Playlist, rhs: *playlists.Playlist) bool {
    return std.mem.order(u8, lhs.name, rhs.name) == .gt;
}
