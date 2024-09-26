const c = @import("root.zig").c;
const std = @import("std");

pub fn testFf() !void {
    const file = "/home/vktrenokh/Music/vk_____________treenokh/Isolation [O07SX0BliAQ].mp3";

    _ = c.avformat_network_init();

    var formatCtx: ?*c.AVFormatContext = null;

    if (c.avformat_open_input(&formatCtx, file.ptr, null, null) != 0) {
        return;
    }
    defer c.avformat_close_input(&formatCtx);

    if (formatCtx == null) {
        return;
    }

    // Retrieve stream information
    if (c.avformat_find_stream_info(formatCtx, null) < 0) {
        return;
    }

    // Extract metadata from the format context
    const metadata = formatCtx.?.metadata;
    if (metadata != null) {
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
    } else {
        std.debug.print("No metadata found.\n", .{});
    }
}
