const ui = @import("../ui/ui.zig");
const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const List = @import("../components/list.zig").List;
const vaxis = @import("vaxis");

fn drawPlaylistContent(music: std.ArrayList(*Playlist), selected_index: usize, music_window: vaxis.Window, music_list: *List) void {
    if (music.items[selected_index].content) |content| {
        music_window.clear();

        music_list.draw(music_window, content.items.len, music_window.width);

        for (content.items, 0..) |track, i| {
            music_list.view.writeCell(music_window, 0, i, vaxis.Cell{ .char = .{
                .width = track.name.len,
                .grapheme = track.name,
            }, .style = ui.style_list_item(music_list.selected == i) });
        }
    } else {
        music_window.clear();

        try ui.drawText(vaxis.widgets.alignment.center(
            music_window,
            ui.logo.len,
            1,
        ), ui.logo, 0, 0);
    }
}

pub fn drawMainView(playlist_list: *List, music: std.ArrayList(*Playlist), music_window: vaxis.Window, music_list: *List) !void {
    for (music.items, 0..) |item, i| {
        playlist_list.view.writeCell(playlist_list.window.?, 0, i, vaxis.Cell{
            .char = .{
                .width = item.name.len,
                .grapheme = item.name,
            },
            .style = ui.style_list_item(playlist_list.selected == i),
        });
    }

    drawPlaylistContent(music, playlist_list.selected, music_window, music_list);
}
