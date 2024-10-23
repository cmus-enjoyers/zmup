const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("ui/ui.zig");
const List = @import("components/list.zig").List;
const playlists = @import("playlists/playlists.zig");
const sorting = @import("playlists/sorting.zig");
const c = @import("root.zig").c;
const time = @import("misc/time.zig");
const colors = @import("misc/colors.zig");
const drawMainView = @import("views/main.zig").drawMainView;
const ffmpeg = @import("./interop/ffmpeg.zig");
const laziness = @import("./keybinds/lazy.zig");
const Metadata = @import("./playlists/metadata.zig").Metadata;

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

    c.av_log_set_level(c.AV_LOG_DEBUG);
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

    var playlist_view = ScrollView{ .vertical_scrollbar = null };
    var music_view = ScrollView{ .vertical_scrollbar = null };
    var playlist_list = List{ .view = &playlist_view };
    var music_list = List{ .view = &music_view };
    var music_window: ?vaxis.Window = null;

    var selected_view = &playlist_list;

    while (true) {
        switch (loop.nextEvent()) {
            .key_press => |key| {
                if (key.matches('q', .{})) {
                    break;
                }

                if (key.matches(13, .{})) {
                    try music.items[playlist_list.selected].loadUntil(music_window.?.height);
                    selected_view = &music_list;
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

        music_window = ui.drawMusicWin(win, playlist_win.width + 2, std.meta.eql(selected_view, &music_list));

        try drawMainView(&playlist_list, music, music_window.?, &music_list);

        // Maybe add this later when we will use non blocking loop.tryEvent().
        // without this program will use 100% of one cpu thread.
        // For now only event-driven rendering
        //
        // std.time.sleep(16670000)

        try vx.render(any_writer);
    }
}
