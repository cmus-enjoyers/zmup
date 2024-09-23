const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const Playlist = struct {
    path: []const u8,
    content: ?std.ArrayList([]const u8) = null,
    allocator: Allocator,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) Playlist {
        return Playlist{ .allocator = allocator, .path = path };
    }

    pub fn deinit(self: Playlist) void {
        if (self.content) |content| {
            for (content.items) |item| {
                self.allocator.free(item);
            }

            content.deinit();
        }
    }

    pub fn load(self: *Playlist, allocator: Allocator) ![][]const u8 {
        if (self.content) |content| {
            return content.items;
        }

        var content = std.ArrayList([]const u8).init(allocator);

        const file = try std.fs.openFileAbsolute(self.path, .{});
        defer file.close();

        const data = try file.readToEndAlloc(
            allocator,
            try file.getEndPos(),
        );
        defer allocator.free(data);

        var iterator = std.mem.splitAny(
            u8,
            data,
            "\n",
        );

        while (iterator.next()) |item| {
            try content.append(try allocator.dupe(u8, item));
        }

        self.content = content;

        return content.items;
    }
};

pub fn isDir(cwd: std.fs.Dir, path: []const u8) bool {
    const stat = cwd.statFile(path) catch {
        return false;
    };

    return stat.kind == .directory;
}

pub fn getPlaylists(allocator: std.mem.Allocator, paths: [][]const u8) ![]Playlist {
    var list = std.ArrayList(Playlist).init(allocator);

    const cwd = fs.cwd();

    for (paths) |path| {
        const dir = isDir(cwd, path);

        if (!dir) {
            var playlist = Playlist.init(allocator, path);
            _ = try playlist.load(allocator);
            try list.append(playlist);
        }
    }

    return list.items;
}

test "Playlist" {
    var playlist = Playlist.init(std.testing.allocator, "/home/vktrenokh/.config/cmus/playlists/bed");
    defer playlist.deinit();

    try std.testing.expect(playlist.content == null);

    _ = try playlist.load(std.testing.allocator);

    try std.testing.expect(playlist.content != null);
}
