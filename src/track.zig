const c = @import("root.zig").c;
const std = @import("std");

pub fn getMetadata(metadata: *c.AVDictionary) void {
    var tag: ?*c.AVDictionaryEntry = null;
    while (true) {
        tag = c.av_dict_get(metadata, "", tag, c.AV_DICT_IGNORE_SUFFIX);
        if (tag == null) break;

        const key = tag.?.key;
        const value = tag.?.value;
        if (key != null and value != null) {
            const keyStr = std.mem.span(key);
            const valueStr = std.mem.span(value);
            std.debug.print("{s}: {s}\n", .{ keyStr, valueStr });
        }
    }
}

pub fn testFf() !void {
    const file = "/home/vktrenokh/Music/jump/ridge-racer-type-4/01 Urban Fragments.flac";

    _ = c.avformat_network_init();

    var format_ctx: ?*c.AVFormatContext = null;

    if (c.avformat_open_input(&format_ctx, file.ptr, null, null) != 0) {
        std.debug.print("no open input", .{});
        return;
    }
    defer c.avformat_close_input(&format_ctx);

    if (format_ctx == null) {
        std.debug.print("no format ctx", .{});
        return;
    }

    if (c.avformat_find_stream_info(format_ctx, null) < 0) {
        std.debug.print("no stream info", .{});
        return;
    }

    if (format_ctx.?.metadata) |metadata| {
        getMetadata(metadata);
    } else {
        std.debug.print("No metadata found.\n", .{});
    }
}
