const playlists = @import("../playlists/playlists.zig");
const std = @import("std");
const time = @import("../misc/time.zig");

pub fn printMusic(allocator: std.mem.Allocator, music: std.ArrayList(*playlists.Playlist)) void {
    for (music.items) |item| {
        const start = try std.time.Instant.now();

        const content = try item.load();

        const end = try std.time.Instant.now();
        const elapsed: f64 = @floatFromInt(end.since(start));

        std.debug.print("{s} took {d:.3}ms with duration {s}\n", .{
            item.name,
            elapsed / std.time.ns_per_ms,
            try time.avTimeToString(allocator, item.duration),
        });

        if (content.len == 0) {
            continue;
        }

        for (content) |track| {
            if (track.metadata) |metadata| {
                std.debug.print("  {s} duration {s}\n", .{ track.name, try time.avTimeContextToString(allocator, metadata.context.?) });
            }
        }
    }
}
