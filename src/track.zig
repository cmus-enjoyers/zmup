const std = @import("std");
const metadata = @import("metadata.zig");

pub const Track = struct {
    metadata: ?*metadata.Metadata = null,
    allocator: std.mem.Allocator,
    path: []const u8,
    name: []const u8,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Track {
        const duped = try allocator.dupe(u8, path);

        return Track{
            .path = duped,
            .name = std.fs.path.stem(duped),
            .allocator = allocator,
        };
    }

    pub fn deinit(self: Track) void {
        self.allocator.dupe(u8, self.path);
    }
};

