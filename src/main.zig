const std = @import("std");
const vaxis = @import("vaxis");
const Cell = vaxis.Cell;
const TextInput = vaxis.widgets.TextInput;
const border = vaxis.widgets.border;

const Event = union(enum) {
    key_press: vaxis.Key,
    winsize: vaxis.Winsize,
    focus_in,
};

const Test = struct {
    first: []const u8,
};

pub fn drawSimpleTable(allocator: std.mem.Allocator, win: vaxis.Window) !void {
    const active_bg: vaxis.Cell.Color = .{ .rgb = .{ 64, 128, 255 } };
    const selected_bg: vaxis.Cell.Color = .{ .rgb = .{ 32, 64, 255 } };

    var tbl: vaxis.widgets.Table.TableContext = .{
        .active_bg = active_bg,
        .selected_bg = selected_bg,
        .header_names = .{ .custom = &.{ "First", "Last", "Username", "Phone#", "Email" } },
        .col_indexes = .{ .by_idx = &.{ 0, 1, 2, 4, 3 } },
    };

    const info = [_]Test{
        .{ .first = "Hello" },
    };

    var multi = std.MultiArrayList(Test){};

    for (info) |value| {
        try multi.append(allocator, value);
    }

    try vaxis.widgets.Table.drawTable(allocator, win, multi, &tbl);
}

pub fn main() !void {
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

    try vx.enterAltScreen(tty.anyWriter());

    var text_input = TextInput.init(allocator, &vx.unicode);
    defer text_input.deinit();

    try vx.queryTerminal(tty.anyWriter(), 1 * std.time.ns_per_s);

    try vx.notify(tty.anyWriter(), "Hello", "Hello world");

    while (true) {
        const event = loop.nextEvent();

        switch (event) {
            .key_press => |key| {
                if (key.matches('q', .{})) {
                    break;
                } else {
                    try text_input.update(.{ .key_press = key });
                }
            },
            .winsize => |ws| try vx.resize(allocator, tty.anyWriter(), ws),
            else => {},
        }

        const win = vx.window();

        win.clear();

        const style: vaxis.Style = .{
            .fg = .{ .index = 100 },
        };

        const child = win.child(.{
            .x_off = win.width / 2 - 20,
            .y_off = win.height / 2 - 3,
            .width = .{ .limit = 40 },
            .height = .{ .limit = 3 },
            .border = .{
                .where = .all,
                .style = style,
            },
        });

        _ = child;

        try drawSimpleTable(allocator, win);

        try vx.render(tty.anyWriter());
    }
}
