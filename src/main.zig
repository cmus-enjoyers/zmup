const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("misc/ui.zig");
const playlists = @import("playlists/playlists.zig");
const sorting = @import("playlists/sorting.zig");
const c = @import("root.zig").c;
const time = @import("misc/time.zig");
const colors = @import("misc/colors.zig");

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

    var playlist_scroll = ScrollView{};

    while (true) {
        const event = loop.nextEvent();

        switch (event) {
            .key_press => |key| {
                if (key.matches('q', .{})) {
                    break;
                }
                if (key.matches('j', .{})) {
                    playlist_scroll.scroll.y +|= 1;
                }

                if (key.matches('k', .{})) {
                    playlist_scroll.scroll.y -|= 1;
                }
            },
            .winsize => |ws| try vx.resize(allocator, any_writer, ws),
            else => {},
        }

        const win = vx.window();

        const playlist_win = ui.drawPlaylistWin(win, 3);

        playlist_scroll.draw(playlist_win, .{ .cols = playlist_win.width, .rows = music.items.len });

        const music_window = ui.drawMusicWin(win, playlist_win.width + 2);
        _ = music_window;

        for (music.items, 0..) |item, i| {
            const style = if (playlist_scroll.scroll.y == i) ui.selected_item_style else undefined;

            playlist_scroll.writeCell(playlist_win, 0, i, vaxis.Cell{
                .char = .{
                    .width = item.name.len,
                    .grapheme = item.name,
                },
                .style = style,
            });
        }

        try vx.render(any_writer);
    }
}
