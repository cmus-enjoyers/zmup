const ui = @import("../ui/ui.zig");
const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const vaxis = @import("vaxis");

pub fn drawMainView(playlist_list: *ui.List, music: std.ArrayList(*Playlist)) !void {
    for (music.items, 0..) |item, i| {
        const style = if (playlist_list.selected == i) ui.selected_item_style else undefined;

        playlist_list.view.writeCell(playlist_list.window.?, 0, i, vaxis.Cell{
            .char = .{
                .width = item.name.len,
                .grapheme = item.name,
            },
            .style = style,
        });
    }
}
