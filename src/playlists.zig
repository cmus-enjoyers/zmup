const std = @import("std");
const fs = std.fs;

pub const Playlist = struct {
    path: []const u8,
    content: ?[][]const u8,

    pub fn load(self: Playlist, allocator: std.mem.Allocator) ![][]const u8 {
        if (self.content) |content| {
            return content;
        }

        const file = try std.fs.openFileAbsolute(self.path, .{});

        const content = try file.readToEndAlloc(allocator, 2 ** 64);
    }
};

pub fn isDir(cwd: std.fs.Dir, path: []const u8) bool {
    const stat = cwd.statFile(path) catch {
        return false;
    };

    return stat.kind == .directory;
}

pub fn getPlaylists(allocator: std.mem.Allocator, paths: [][]const u8) ![]bool {
    var list = std.ArrayList(bool).init(allocator);

    const cwd = fs.cwd();

    for (paths) |path| {
        const dir = isDir(cwd, path);

        try list.append(dir);
    }

    return list.items;
}
