const ui = @import("../ui/ui.zig");
const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const vaxis = @import("vaxis");

pub fn drawPlaylistContent(music: std.ArrayList(*Playlist), selected_index: usize, music_window: vaxis.Window, music_list: *ui.List) void {
    if (music.items[selected_index].content) |content| {
        music_list.draw(music_window, content.items.len, music_window.width);

        for (content.items, 0..) |track, j| {
            music_list.view.writeCell(music_window, 0, j, vaxis.Cell{
                .char = .{
                    .width = track.name.len,
                    .grapheme = track.name,
                },
            });
        }
    } else {
        music_window.clear();
        try ui.drawText(music_window, ui.logo, 0, 0);
    }
}

pub fn drawMainView(playlist_list: *ui.List, music: std.ArrayList(*Playlist), music_window: vaxis.Window, music_list: *ui.List) !void {
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

    drawPlaylistContent(music, playlist_list.selected, music_window, music_list);
}
