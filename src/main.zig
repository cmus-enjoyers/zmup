const std = @import("std");
const vaxis = @import("vaxis");
const ui = @import("ui.zig");
const playlists = @import("playlists.zig");
const sorting = @import("sorting.zig");
const track = @import("track.zig");
const metadata = @import("metadata.zig");
const c = @import("root.zig").c;

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

pub fn testing(data: *metadata.Metadata) !void {
    var iterator = try data.iterate();
    while (try iterator.next()) |value| {
        std.debug.print("{s} - {s}\n", .{ value.key, value.value });
    }
}

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
    //
    const home = std.posix.getenv("HOME");
    c.av_log_set_level(c.AV_LOG_QUIET);

    var playlist_paths: [1][]const u8 = .{try std.fs.path.join(allocator, &[2][]const u8{ home.?, ".config/cmus/playlists" })};

    const music = try playlists.getPlaylists(allocator, &playlist_paths);
    try sorting.sort(music, sorting.SortMethods.greater);
    defer {
        for (music.items) |item| {
            item.deinit();
            allocator.destroy(item);
        }
        music.deinit();
    }

    for (music.items) |item| {
        const content = item.load() catch continue;

        for (content) |track| {
            if (track.metadata) |value| {
                var iterator = value.iterate() catch continue;

                while (try iterator.next()) |x| {
                    std.debug.print("{s} {s}\n", .{ x.key, x.value });
                }
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
