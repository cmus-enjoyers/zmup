const std = @import("std");
const Metadata = @import("metadata.zig").Metadata;

pub const Track = struct {
    metadata: ?*Metadata = null,
    allocator: std.mem.Allocator,
    path: []const u8,
    name: []const u8,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Track {
        const track_metadata = try allocator.create(Metadata);
        const duped_path = try std.fs.path.resolve(allocator, &[1][]const u8{path});
        const stem = std.fs.path.stem(duped_path);

        track_metadata.* = Metadata.init(allocator, duped_path) catch {
            return Track{
                .path = duped_path,
                .name = stem,
                .allocator = allocator,
            };
        };

        return Track{
            .path = duped_path,
            .name = stem,
            .allocator = allocator,
            .metadata = track_metadata,
        };
    }

    pub fn deinit(self: Track) void {
        self.allocator.free(self.path);

        if (self.metadata) |metadata| {
            metadata.deinit();
            self.allocator.destroy(metadata);
        }
    }
};

test "Track" {
    const track = try Track.init(std.testing.allocator, "/some/path");
    defer track.deinit();

    try std.testing.expect(std.mem.eql(u8, track.name, "path"));
}
