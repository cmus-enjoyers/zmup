const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("misc/ui.zig");
const playlists = @import("playlists/playlists.zig");
const sorting = @import("sorting.zig");
const Track = @import("track.zig").Track;
const c = @import("root.zig").c;
const time = @import("time.zig");

const Cell = vaxis.Cell;
const TextInput = vaxis.widgets.TextInput;
const border = vaxis.widgets.border;

const Event = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
    focus_in,
};

// TODO: add zmup (github.com/cmus-enjoyers/sneaky-cmup-10) and some cli things
// TODO: man pages?!?!?!?!
pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    const allocator = arena.allocator();

    // var tty = try vaxis.Tty.init();
    // defer tty.deinit();
    //
    // var vx = try vaxis.init(allocator, .{});
    // defer vx.deinit(allocator, tty.anyWriter());
    //
    // var loop: vaxis.Loop(Event) = .{
    //     .tty = &tty,
    //     .vaxis = &vx,
    // };
    // try loop.init();
    //
    // try loop.start();
    // defer loop.stop();
    //
    // const any_writer = tty.anyWriter();
    //
    // try vx.enterAltScreen(any_writer);
    //
    // var text_input = TextInput.init(allocator, &vx.unicode);
    // defer text_input.deinit();
    //
    // try vx.queryTerminal(any_writer, 1 * std.time.ns_per_s);

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

    for (music.items) |item| {
        const start = try std.time.Instant.now();

        const content = try item.load();

        const end = try std.time.Instant.now();
        const elapsed: f64 = @floatFromInt(end.since(start));

        std.debug.print("{s} took {d:.3}ms with duration {s}\n", .{
            item.name,
            elapsed / std.time.ns_per_ms,
            try time.avTimeToString(allocator, item.duration),
        });

        if (content.len == 0) {
            continue;
        }

        for (content) |track| {
            if (track.metadata) |metadata| {
                _ = metadata;
                // std.debug.print("  {s} duration {s}\n", .{ track.name, try pretty.avTimeToString(allocator, metadata.context.?) });
            }
        }
    }

    // while (true) {
    //     const event = loop.nextEvent();
    //
    //     switch (event) {
    //         .key_press => |key| {
    //             if (key.matches('q', .{})) {
    //                 break;
    //             } else {
    //                 try text_input.update(.{ .key_press = key });
    //             }
    //         },
    //         .winsize => |ws| try vx.resize(allocator, any_writer, ws),
    //         else => {},
    //     }
    //
    //     const win = vx.window();
    //
    //     // win.clear();
    //
    //     const style: vaxis.Style = .{
    //         .fg = .{ .index = 100 },
    //     };
    //
    //     const child = win.child(.{
    //         .x_off = win.width / 2 - 20,
    //         .y_off = win.height / 2 - 3,
    //         .width = .{ .limit = 40 },
    //         .height = .{ .limit = 3 },
    //         .border = .{
    //             .where = .all,
    //             .style = style,
    //         },
    //     });
    //
    //     text_input.draw(child);
    //
    //     try ui.drawSimpleTable(allocator, win);
    //
    //     for (x.items, 0..) |item, i| {
    //         _ = item;
    //         try ui.drawText(win, "hello", 0, i);
    //     }
    //
    //     // try vx.render(any_writer);
    // }
}
