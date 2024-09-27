const c = @import("root.zig").c;
const std = @import("std");

const MetadataPair = struct {
    key: []const u8,
    value: []const u8,
};

const Iterator = struct {
    dictionary: *const c.AVDictionary,
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

const Metadata = struct {
    context: *c.AVFormatContext,

    pub fn init(context: ?*c.AVFormatContext) MetadataError!Metadata {
        if (context) |value| {
            return Metadata{ .context = value };
        }

        return MetadataError.NoMetadata;
    }

    pub fn iterate(self: *Metadata) MetadataError!Iterator {
        if (self.context.metadata) |metadata| {
            return Iterator{ .dictionary = metadata };
        }

        return MetadataError.NoMetadata;
    }

    pub fn deinit(self: *Metadata) void {
        c.avformat_close_input(@ptrCast(&self.context));
    }
};

pub const MetadataError = error{
    CannotOpenInput,
    ContextIsNull,
    StreamInfoNotFound,
    NoMetadata,
};

pub fn getMetadata(path: []const u8) MetadataError!Metadata {
    _ = c.avformat_network_init();

    var format_ctx: ?*c.AVFormatContext = null;

    if (c.avformat_open_input(&format_ctx, path.ptr, null, null) != 0) {
        return MetadataError.CannotOpenInput;
    }

    if (c.avformat_find_stream_info(format_ctx, null) != 0) {
        return MetadataError.StreamInfoNotFound;
    }

    return try Metadata.init(format_ctx);
}
