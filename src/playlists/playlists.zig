const std = @import("std");
const tracks = @import("track.zig");
const Track = tracks.Track;
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const Playlist = struct {
    path: []const u8,
    name: []const u8,
    content: ?std.ArrayList(*Track) = null,
    contentUnsplitted: ?[]const u8 = null,
    allocator: Allocator,
    iterator: ?*std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence) = null,
    duration: i64 = 0,

    pub fn init(
        allocator: std.mem.Allocator,
        path: []const u8,
    ) !Playlist {
        const duped = try allocator.dupe(u8, path);

        return Playlist{
            .allocator = allocator,
            .path = duped,
            .name = std.fs.path.stem(duped),
        };
    }

    pub fn deinit(self: Playlist) void {
        if (self.content) |content| {
            content.deinit();
        }

        if (self.contentUnsplitted) |content| {
            self.allocator.free(content);
        }

        if (self.iterator) |iterator| {
            self.allocator.destroy(iterator);
        }

        self.allocator.free(self.path);
    }

    pub fn createTrack(self: *Playlist, path: []const u8) *Track {
        const track_ptr = try self.allocator.create(Track);

        track_ptr.* = try Track.init(self.allocator, try self.allocator.dupe(u8, path));

        return track_ptr;
    }

    pub fn load(self: *Playlist) ![]*Track {
        if (self.content) |content| {
            return content.items;
        }

        var content = std.ArrayList(*Track).init(self.allocator);

        const file = try std.fs.openFileAbsolute(self.path, .{});
        defer file.close();

        const data = try file.readToEndAlloc(self.allocator, try file.getEndPos());

        var iterator = std.mem.splitSequence(
            u8,
            data,
            "\n",
        );

        while (iterator.next()) |item| {
            if (item.len == 0) {
                continue;
            }

            const track = self.createTrack(item);

            if (track.metadata) |metadata| {
                self.duration += metadata.duration;
            }

            try content.append(track);
        }

        self.content = content;
        self.contentUnsplitted = data;

        return content.items;
    }

    pub fn loadUntil(self: *Playlist, until: usize) !void {
        var content = std.ArrayList(*Track).init(self.allocator);

        const file = try std.fs.openFileAbsolute(self.path, .{});
        defer file.close();

        const data = try file.readToEndAlloc(self.allocator, try file.getEndPos());

        var iterator = std.mem.splitSequence(
            u8,
            data,
            "\n",
        );

        var i: usize = 0;

        while (iterator.next()) |item| : ({
            i += 1;
        }) {
            if (i == until) {
                const ptr = try self.allocator.create(std.mem.SplitIterator(u8, std.mem.DelimiterType.sequence));

                ptr.* = iterator;

                self.iterator = ptr;
                break;
            }

            if (item.len == 0) {
                continue;
            }

            const track_ptr = try self.allocator.create(Track);

            track_ptr.* = try Track.init(self.allocator, try self.allocator.dupe(u8, item));

            if (track_ptr.metadata) |metadata| {
                self.duration += metadata.duration;
            }

            try content.append(track_ptr);
        }

        self.content = content;
        self.contentUnsplitted = data;
    }
};

pub fn appendPlaylist(list: *std.ArrayList(*Playlist), path: []const u8) !void {
    const ptr = try list.allocator.create(Playlist);

    ptr.* = try Playlist.init(list.allocator, path);

    try list.append(ptr);
}

pub fn appendPlaylistCollection(list: *std.ArrayList(*Playlist), path: []const u8) !void {
    var sub_playlist = std.ArrayList(*Playlist).init(list.allocator);
    defer sub_playlist.deinit();

    var dir = try fs.openDirAbsolute(path, .{ .iterate = true });
    defer dir.close();

    var iterator = dir.iterate();

    while (try iterator.next()) |item| {
        switch (item.kind) {
            .file => {
                const item_path = std.fs.path.join(list.allocator, &[2][]const u8{ path, item.name }) catch continue;
                defer list.allocator.free(item_path);

                appendPlaylist(&sub_playlist, item_path) catch continue;
            },
            else => {},
        }
    }

    try list.appendSlice(sub_playlist.items);
}

pub fn getPlaylists(allocator: std.mem.Allocator, paths: [][]const u8) !std.ArrayList(*Playlist) {
    var list = std.ArrayList(*Playlist).init(allocator);

    const cwd = fs.cwd();

    for (paths) |path| {
        const stat = cwd.statFile(path) catch continue;

        switch (stat.kind) {
            .file => appendPlaylist(&list, path) catch continue,
            .directory => appendPlaylistCollection(&list, path) catch continue,
            else => {},
        }
    }

    return list;
}

test "Playlist" {
    var playlist = try Playlist.init(std.testing.allocator, "/home/vktrenokh/.config/cmus/playlists/bed");
    defer playlist.deinit();

    try std.testing.expect(playlist.content == null);

    const items = try playlist.load();
    try std.testing.expect(items.len > 0);

    try std.testing.expect(playlist.content != null);

    var paths: [1][]const u8 = .{
        "/home/vktrenokh/.config/cmus/playlists/",
    };
    const playlists = try getPlaylists(std.testing.allocator, &paths);
    defer {
        for (playlists.items) |item| {
            item.deinit();
            std.testing.allocator.destroy(item);
        }
        playlists.deinit();
    }
    try std.testing.expect(playlists.items.len > 0);
}
