const std = @import("std");
const metadata = @import("metadata.zig");

pub const Track = struct {
    metadata: ?*metadata.Metadata = null,
    allocator: std.mem.Allocator,
    path: []const u8,
    name: []const u8,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Track {
        const duped = try allocator.dupe(u8, path);
        const track_metadata = try allocator.create(metadata.Metadata);

        track_metadata.* = metadata.getMetadata(allocator, duped) catch {
            return Track{
                .path = duped,
                .name = std.fs.path.stem(duped),
                .allocator = allocator,
            };
        };

        return Track{
            .path = duped,
            .name = std.fs.path.stem(duped),
            .allocator = allocator,
            .metadata = track_metadata,
        };
    }

    pub fn deinit(self: Track) void {
        self.allocator.free(self.path);

        if (self.metadata) |value| {
            self.allocator.destroy(value);
            value.deinit();
        }
    }
};
