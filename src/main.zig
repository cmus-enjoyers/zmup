const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("ui/ui.zig");
const playlists = @import("playlists/playlists.zig");
const sorting = @import("playlists/sorting.zig");
const c = @import("root.zig").c;
const time = @import("misc/time.zig");
const colors = @import("misc/colors.zig");
const main_view = @import("views/main.zig");

const Cell = vaxis.Cell;
const TextInput = vaxis.widgets.TextInput;
const border = vaxis.widgets.border;
const ScrollView = vaxis.widgets.ScrollView;

const Event = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
    focus_in,
};

// TODO: add zmup (github.com/cmus-enjoyers/sneaky-cmup-10) and some cli things
// TODO: man pages?!?!?!?!
pub fn main() !void {
    // TODO: maybe change the allocator
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    var tty = try vaxis.Tty.init();
    defer tty.deinit();

    var vx = try vaxis.init(allocator, .{});
    defer vx.deinit(allocator, tty.anyWriter());

    var loop: vaxis.Loop(Event) = .{
        .tty = &tty,
        .vaxis = &vx,
    };
    try loop.init();

    try loop.start();
    defer loop.stop();

    const any_writer = tty.anyWriter();

    try vx.enterAltScreen(any_writer);

    try vx.queryTerminal(any_writer, 1 * std.time.ns_per_s);

    c.av_log_set_level(c.AV_LOG_QUIET);

    try vx.setTitle(any_writer, "Zig music player");

    const home = std.posix.getenv("HOME");

    var playlist_paths: [1][]const u8 = .{try std.fs.path.join(allocator, &[2][]const u8{ home.?, ".config/cmus/playlists" })};

    const music = try playlists.getPlaylists(allocator, &playlist_paths);
    try sorting.sort(music, sorting.SortMethods.greater);
    defer {
        for (music.items) |track| {
            track.deinit();
            allocator.destroy(track);
        }
        music.deinit();
    }

    var playlist_view = ScrollView{};
    var music_view = ScrollView{};
    var playlist_list = ui.List{ .view = &playlist_view };
    var music_list = ui.List{ .view = &music_view };

    var selected_view = &playlist_list;

    while (true) {
        const event = loop.nextEvent();

        switch (event) {
            .key_press => |key| {
                if (key.matches('q', .{})) {
                    break;
                }

                if (key.matches(13, .{})) {
                    // TODO: optimize playlist loading. pg3d playlist causes
                    // microfreeze whilie loading it, in cmus it doesn't
                    _ = try music.items[playlist_list.selected].load();
                }

                if (key.matches(' ', .{})) {
                    selected_view = if (std.meta.eql(selected_view, &music_list)) &playlist_list else &music_list;
                }

                selected_view.input(key);
            },
            .winsize => |ws| try vx.resize(allocator, any_writer, ws),
            else => {},
        }

        const win = vx.window();

        const playlist_win = ui.drawPlaylistWin(win, 3, std.meta.eql(selected_view, &playlist_list));

        playlist_list.draw(playlist_win, playlist_win.width, music.items.len);

        const music_window = ui.drawMusicWin(win, playlist_win.width + 2, std.meta.eql(selected_view, &music_list));
        _ = music_window;

        try main_view.drawMainView(&playlist_list, music);
        // for (music.items, 0..) |item, i| {
        //     const style = if (playlist_list.selected == i) ui.selected_item_style else undefined;
        //
        //     playlist_list.view.writeCell(playlist_win, 0, i, vaxis.Cell{
        //         .char = .{
        //             .width = item.name.len,
        //             .grapheme = item.name,
        //         },
        //         .style = style,
        //     });
        //
        //     // TODO: change this indexing to playlist_list.selected
        //     if (music.items[playlist_list.selected].content) |content| {
        //         music_list.draw(music_window, content.items.len, music_window.width);
        //
        //         for (content.items, 0..) |track, j| {
        //             music_list.view.writeCell(music_window, 0, j, vaxis.Cell{
        //                 .char = .{
        //                     .width = track.name.len,
        //                     .grapheme = track.name,
        //                 },
        //             });
        //         }
        //     } else {
        //         music_window.clear();
        //         try ui.drawText(music_window, ui.logo, 0, 0);
        //     }
        // }

        try vx.render(any_writer);
    }
}
