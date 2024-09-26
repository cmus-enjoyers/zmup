const c = @import("root.zig").c;
const std = @import("std");

const Metadata = struct {
    key: []const u8,
    value: []const u8,
};

const Iterator = struct {
    dictionary: *c.AVDictionary,
    tag: ?*c.AVDictionaryEntry = null,

    pub fn next(self: *Iterator) ?Metadata {
        self.tag = c.av_dict_get(self.dictionary, "", self.tag, c.AV_DICT_IGNORE_SUFFIX);

        if (self.tag) |value| {
            return Metadata{
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

pub fn getMetadata(path: []const u8) MetadataError!Iterator {
    _ = c.avformat_network_init();

    var format_ctx: ?*c.AVFormatContext = null;

    if (c.avformat_open_input(&format_ctx, path.ptr, null, null) != 0) {
        return MetadataError.CannotOpenInput;
    }
    // defer c.avformat_close_input(&format_ctx);

    if (format_ctx == null) {
        return MetadataError.ContextIsNull;
    }

    if (c.avformat_find_stream_info(format_ctx, null) < 0) {
        return MetadataError.StreamInfoNotFound;
    }

    if (format_ctx.?.metadata) |metadata| {
        return Iterator{ .dictionary = metadata };
    }

    return MetadataError.NoMetadata;
}
