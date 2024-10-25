const std = @import("std");
const Playlist = @import("../playlists/playlists.zig");

pub fn search(allocator: std.mem.Allocator, list: *const std.ArrayList(*Playlist), string: []const u8) std.ArrayList(*Playlist) {
    const filtered = std.ArrayList(*Playlist).init(allocator);

    for (list.items) |item| {
        if (std.ascii.indexOfIgnoreCasePos(item.name, 0, string)) {
            filtered.append(item);
        }
    }

    return filtered;
}
