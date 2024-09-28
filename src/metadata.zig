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

pub const Metadata = struct {
    context: **c.AVFormatContext,

    pub fn init(context: **c.AVFormatContext) MetadataError!Metadata {
        return Metadata{ .context = context };
    }

    pub fn iterate(self: *Metadata) MetadataError!Iterator {
        // if (self.context.metadata) |metadata| {
        //     std.debug.print("in the capture (iterator) {any}\n", .{metadata});
        //     return Iterator{ .dictionary = metadata };
        // }
        std.debug.print("data = {any}\n", .{self.context});

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

// TODO: allocator.create
pub fn getMetadata(allocator: std.mem.Allocator, path: []const u8) !Metadata {
    const ptr = try allocator.create(*c.AVFormatContext);
    var duped_path = try allocator.dupe(u8, path);
    _ = &duped_path;

    ptr.* = c.avformat_alloc_context();

    if (c.avformat_open_input(@ptrCast(ptr), "/home/vktrenokh/Music/jump/ridge-racer-type-4/17 Move Me.flac", null, null) != 0) {
        return MetadataError.CannotOpenInput;
    }

    std.debug.print("after oepn input", .{});

    // if (c.avformat_find_stream_info(@ptrCast(ptr), null) != 0) {
    //     return MetadataError.StreamInfoNotFound;
    // }
    std.debug.print("after find stream info", .{});

    return try Metadata.init(ptr);
}
