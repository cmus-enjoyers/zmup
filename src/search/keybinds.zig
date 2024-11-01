const std = @import("std");
const vaxis = @import("vaxis");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const search = @import("search.zig").search;

fn clearTextInput(text_input: *?vaxis.widgets.TextInput) void {
    text_input.*.?.deinit();
    text_input.* = null;
}

pub fn input(
    allocator: std.mem.Allocator,
    key: vaxis.Key,
    text_input: *?vaxis.widgets.TextInput,
    music_to_display: *std.ArrayList(*Playlist),
    music: *std.ArrayList(*Playlist),
) !void {
    try text_input.*.?.update(.{ .key_press = key });

    if (key.matches(27, .{})) {
        clearTextInput(text_input);
    }

    if (key.matches(13, .{})) {
        music_to_display.* = try search(
            allocator,
            music,
            try text_input.*.?.buf.toOwnedSlice(),
        );
        clearTextInput(text_input);
    }
}
