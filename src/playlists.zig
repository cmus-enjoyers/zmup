const std = @import("std");
const fs = std.fs;

pub const Playlist = struct {
    path: []const u8,
    content: ?[][]const u8 = null,

    pub fn load(self: *Playlist, allocator: std.mem.Allocator) ![][]const u8 {
        if (self.content) |content| {
            return content;
        }

        var content = std.ArrayList([]const u8).init(allocator);

        const file = try std.fs.openFileAbsolute(self.path, .{});

        var iterator = std.mem.splitAny(
            u8,
            try file.readToEndAlloc(
                allocator,
                try file.getEndPos(),
            ),
            "\n",
        );

        while (iterator.next()) |item| {
            try content.append(item);
        }

        self.content = content.items;

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
            const playlist = Playlist{ .path = path };
            _ = try playlist.load(allocator);
            try list.append(playlist);
        }
    }

    return list.items;
}
