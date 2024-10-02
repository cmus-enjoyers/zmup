const c = @import("root.zig").c;
const ffmpeg = @import("ffmpeg.zig");
const std = @import("std");

const MetadataPair = struct {
    key: []const u8,
    value: []const u8,
};

const Iterator = struct {
    allocator: std.mem.Allocator,
    dictionary: *c.AVDictionary,
    tag: ?*c.AVDictionaryEntry = null,

    pub fn next(self: *Iterator) ?MetadataPair {
        self.tag = c.av_dict_get(self.dictionary, "", self.tag, c.AV_DICT_IGNORE_SUFFIX);

        if (self.tag) |value| {
            return MetadataPair{
                .key = std.mem.span(value.key),
                .value = std.mem.span(value.value),
            };
        }

        return null;
    }
};

pub const MetadataError = error{
    CannotOpenInput,
    ContextIsNull,
    StreamInfoNotFound,
    NoMetadata,
};

pub const Metadata = struct {
    context: ?**c.AVFormatContext = null,
    allocator: std.mem.Allocator,
    duration: i64,

    pub fn init(allocator: std.mem.Allocator, path: []const u8) !Metadata {
        const ptr = try allocator.create(*c.AVFormatContext);
        errdefer {
            c.avformat_close_input(@ptrCast(ptr));

            allocator.destroy(ptr);
        }

        ptr.* = c.avformat_alloc_context();

        try ffmpeg.avFormatOpenInput(@ptrCast(ptr), @ptrCast(path), null, null);
        try ffmpeg.avFormatFindStreamInfo(@ptrCast(ptr.*), null);

        return Metadata{
            .context = ptr,
            .allocator = allocator,
            .duration = ptr.*.duration,
        };
    }

    pub fn iterate(self: Metadata) MetadataError!Iterator {
        if (self.context.?.*.metadata) |metadata| {
            return Iterator{ .dictionary = metadata, .allocator = self.allocator };
        }
        return MetadataError.NoMetadata;
    }

    pub fn deinit(self: *Metadata) void {
        c.avformat_close_input(@ptrCast(self.context));

        self.allocator.destroy(self.context);
    }
};
