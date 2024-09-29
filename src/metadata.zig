const c = @import("root.zig").c;
const std = @import("std");

const MetadataPair = struct {
    key: []const u8,
    value: []const u8,
};

const Iterator = struct {
    allocator: std.mem.Allocator,
    dictionary: *c.AVDictionary,
    tag: ?*c.AVDictionaryEntry = null,

    pub fn next(self: *Iterator) !?MetadataPair {
        self.tag = c.av_dict_get(null, "", null, c.AV_DICT_IGNORE_SUFFIX);

        if (self.tag) |value| {
            return MetadataPair{
                .key = std.mem.span(value.key),
                .value = std.mem.span(value.value),
            };
        }

        return null;
    }
};

pub const Metadata = struct {
    context: ?**c.AVFormatContext = null,
    allocator: std.mem.Allocator,

    pub fn iterate(self: Metadata) MetadataError!Iterator {
        if (self.context) |context| {
            if (context.*.*.metadata) |d| {
                std.debug.print("test", .{});
                return Iterator{ .dictionary = d, .allocator = self.allocator };
            }

            return MetadataError.NoMetadata;
        }
        return MetadataError.NoMetadata;
    }

    pub fn deinit(self: *Metadata) void {
        _ = self;
        std.debug.print("x", .{});
        // c.avformat_close_input(@ptrCast(&self.context));
    }
};

pub const MetadataError = error{
    CannotOpenInput,
    ContextIsNull,
    StreamInfoNotFound,
    NoMetadata,
};

pub fn getMetadata(allocator: std.mem.Allocator, path: []const u8) !Metadata {
    const ptr = try allocator.create(*c.AVFormatContext);

    ptr.* = c.avformat_alloc_context();

    var context: ?*c.AVFormatContext = null;

    if (c.avformat_open_input(@ptrCast(&context), @ptrCast(path), null, null) != 0) {
        return MetadataError.CannotOpenInput;
    }

    if (c.avformat_find_stream_info(@ptrCast(context), null) != 0) {
        return MetadataError.StreamInfoNotFound;
    }

    if (context) |*value| {
        return Metadata{
            .context = value,
            .allocator = allocator,
        };
    }

    return MetadataError.ContextIsNull;
}
