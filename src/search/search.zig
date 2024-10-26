const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;

pub fn search(allocator: std.mem.Allocator, list: *std.ArrayList(*Playlist), string: []const u8) !std.ArrayList(*Playlist) {
    var filtered = std.ArrayList(*Playlist).init(allocator);

    for (list.items) |item| {
        if (std.ascii.indexOfIgnoreCasePos(item.name, 0, string) != null) {
            try filtered.append(item);
        }
    }

    return filtered;
}
