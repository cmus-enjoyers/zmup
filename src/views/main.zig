const ui = @import("../ui/ui.zig");
const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const List = @import("../components/list.zig").List;
const vaxis = @import("vaxis");
const time = @import("../misc/time.zig");

fn drawPlaylistContent(music: std.ArrayList(*Playlist), selected_index: usize, music_window: vaxis.Window, music_list: *List) !void {
    if (music.items.len == 0) {
        return;
    }

    if (music.items[selected_index].content) |content| {
        music_window.clear();

        music_list.draw(music_window, content.items.len, music_window.width);

        for (content.items, 0..) |track, i| {
            music_list.view.writeCell(music_window, 0, i, vaxis.Cell{
                .char = .{
                    .width = @intCast(track.name.len),
                    .grapheme = track.name,
                },
                .style = ui.style_list_item(music_list.selected == i),
            });
        }

        const duration = try music.items[selected_index].getReadableDuration();

        _ = music_window.printSegment(.{ .text = duration }, .{
            .col_offset = @intCast(music_window.width - duration.len),
        });
    } else {
        music_window.clear();

        try ui.drawText(vaxis.widgets.alignment.center(
            music_window,
            ui.logo.len,
            1,
        ), ui.logo, 0, 0);
    }
}

pub fn drawMainView(allocator: std.mem.Allocator, playlist_list: *List, music: std.ArrayList(*Playlist), music_window: vaxis.Window, music_list: *List) !void {
    _ = allocator;

    if (music.items.len == 0) {
        if (playlist_list.window) |window| {
            const empty_text = "No playlists :(";

            try ui.drawText(vaxis.widgets.alignment.center(
                window,
                empty_text.len,
                1,
            ), empty_text, 0, 0);
        }
    } else {
        for (music.items, 0..) |item, i| {
            if (playlist_list.window) |window| {
                const width = @min(window.width, item.name.len);

                playlist_list.view.writeCell(playlist_list.window.?, 0, i, vaxis.Cell{
                    .char = .{
                        .width = @intCast(width),
                        .grapheme = item.name[0..width],
                    },
                    .style = ui.style_list_item(playlist_list.selected == i),
                });
            }
        }
    }

    var x: [64]u8 = [1]u8{0} ** 64;

    _ = try std.fmt.bufPrint(&x, "{} {}", .{ music_list.selected, music_list.view.scroll.y });

    try drawPlaylistContent(music, playlist_list.selected, music_window, music_list);

    _ = music_window.printSegment(.{ .text = &x }, .{
        .row_offset = music_window.height - 1,
        .col_offset = @intCast(music_window.width - x[0..std.mem.indexOf(u8, &x, &[_]u8{0}).?].len),
    });
}
