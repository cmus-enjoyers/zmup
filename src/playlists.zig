const std = @import("std");
const fs = std.fs;

pub const Playlist = struct {
    path: []const u8,
};

pub fn getPlaylists(allocator: std.mem.Allocator, paths: [][]const u8) ![]bool {
    var list = std.ArrayList(bool).init(allocator);

    for (paths) |path| {
        const stat = try fs.cwd().statFile(path);
        const isDir = stat.kind == .directory;

        try list.append(isDir);
    }

    return list.items;
}
