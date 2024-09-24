const std = @import("std");
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const Playlist = struct {
    path: []const u8,
    name: []const u8,
    content: ?std.ArrayList([]const u8) = null,
    contentUnsplitted: ?[]const u8 = null,
    allocator: Allocator,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) Playlist {
        return Playlist{
            .allocator = allocator,
            .path = path,
            .name = std.fs.path.stem(path),
        };
    }

    pub fn deinit(self: Playlist) void {
        if (self.content) |content| {
            content.deinit();
        }

        if (self.contentUnsplitted) |content| {
            self.allocator.free(content);
        }
    }

    pub fn load(self: *Playlist) ![][]const u8 {
        if (self.content) |content| {
            return content.items;
        }

        var content = std.ArrayList([]const u8).init(self.allocator);

        const file = try std.fs.openFileAbsolute(self.path, .{});
        defer file.close();

        const data =
            try file.readToEndAlloc(self.allocator, try file.getEndPos());

        var iterator = std.mem.splitSequence(
            u8,
            data,
            "\n",
        );

        while (iterator.next()) |item| {
            if (item.len == 0) {
                continue;
            }

            try content.append(item);
        }

        self.content = content;
        self.contentUnsplitted = data;

        return content.items;
    }
};

pub fn appendPlaylist(list: *std.ArrayList(*Playlist), path: []const u8) !void {
    const ptr = try list.allocator.create(Playlist);

    ptr.* = Playlist.init(list.allocator, path);

    try list.append(ptr);
}

pub fn appendPlaylistCollection(list: *std.ArrayList(*Playlist), path: []const u8) !void {
    var sub_playlist = std.ArrayList(*Playlist).init(list.allocator);

    var dir = try fs.openDirAbsolute(path, .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();

    while (try iterator.next()) |item| {
        switch (item.kind) {
            .file => try appendPlaylist(
                &sub_playlist,
                try std.fs.path.join(list.allocator, &[2][]const u8{ path, item.name }),
            ),
            else => {},
        }
    }

    try list.appendSlice(sub_playlist.items);
}

pub fn getPlaylists(allocator: std.mem.Allocator, paths: [][]const u8) !std.ArrayList(*Playlist) {
    var list = std.ArrayList(*Playlist).init(allocator);

    const cwd = fs.cwd();

    for (paths) |path| {
        const stat = try cwd.statFile(path);

        switch (stat.kind) {
            .file => try appendPlaylist(&list, path),
            else => try appendPlaylistCollection(&list, path),
        }
    }

    return list;
}

test "Playlist" {
    var playlist = Playlist.init(std.testing.allocator, "/home/vktrenokh/.config/cmus/playlists/bed");
    defer playlist.deinit();

    try std.testing.expect(playlist.content == null);

    const items = try playlist.load();
    try std.testing.expect(items.len > 0);

    try std.testing.expect(playlist.content != null);
}
