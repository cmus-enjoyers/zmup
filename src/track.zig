const std = @import("std");
const Metadata = @import("metadata.zig").Metadata;

pub const Track = struct {
    metadata: ?*Metadata = null,
    allocator: std.mem.Allocator,
    path: []const u8,
    name: []const u8,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Track {
        const duped = try allocator.dupe(u8, path);
        const track_metadata = try allocator.create(Metadata);
        const stem = std.fs.path.stem(duped);

        track_metadata.* = Metadata.init(allocator, duped) catch {
            return Track{
                .path = duped,
                .name = stem,
                .allocator = allocator,
            };
        };

        return Track{
            .path = duped,
            .name = stem,
            .allocator = allocator,
            .metadata = track_metadata,
        };
    }

    pub fn deinit(self: Track) void {
        self.allocator.free(self.path);

        if (self.metadata) |metadata| {
            self.allocator.destroy(metadata);
            metadata.deinit();
        }
    }
};
