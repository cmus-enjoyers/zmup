const std = @import("std");
const vaxis = @import("vaxis");

const Window = vaxis.Window;

pub fn drawText(win: vaxis.Window, text: []const u8, x_offset: usize, y_offset: usize) !void {
    const style: vaxis.Style = .{ .fg = .{
        .rgb = .{255} ** 3,
    } };

    const segment: vaxis.Segment = .{ .text = text, .style = style };

    _ = try win.printSegment(segment, .{ .row_offset = y_offset, .col_offset = x_offset });
}

pub const white_rgb = .{255} ** 3;
pub const black_rgb = .{0} ** 3;

pub const green_border: vaxis.Window.BorderOptions = .{
    .style = .{ .fg = .{ .rgb = .{ 0xc3, 0xe8, 0x8d } } },
    .where = .all,
};

pub const white_border: vaxis.Window.BorderOptions = .{
    .style = .{ .fg = .{ .rgb = white_rgb } },
    .where = .all,
};

pub const selected_item_style: vaxis.Style = .{
    .italic = true,
    .bg = .{
        .rgb = white_rgb,
    },
    .fg = .{
        .rgb = black_rgb,
    },
};

pub fn setBlockCursor(win: vaxis.Window) void {
    win.setCursorShape(vaxis.Cell.CursorShape.block);
}

pub fn border(condition: bool) vaxis.Window.BorderOptions {
    return if (condition == true) green_border else white_border;
}

pub fn drawPlaylistWin(parent: Window, part: usize, is_selected: bool) Window {
    return parent.child(.{
        .border = border(is_selected),
        .width = .{ .limit = parent.width / part },
        .height = .{ .limit = parent.height },
    });
}

pub fn drawMusicWin(parent: Window, off: usize, is_selected: bool) Window {
    return parent.child(.{
        .border = border(is_selected),
        .x_off = off,
    });
}

const ContentSize = struct {
    cols: usize,
    rows: usize,
};

pub const List = struct {
    view: *vaxis.widgets.ScrollView,
    selected: usize = 0,
    window: ?vaxis.Window = null,

    pub fn input(self: *List, key: vaxis.Key) void {
        if (self.window) |value| {
            if (key.matches('j', .{})) {
                self.selected +|= 1;

                if (self.selected >= self.view.scroll.y + value.height - 2) {
                    self.view.scroll.y +|= 1;
                }
            }

            if (key.matches('k', .{})) {
                self.selected -|= 1;

                if (self.selected < self.view.scroll.y) {
                    self.view.scroll.y -|= 1;
                }
            }

            if (key.matches('G', .{})) {
                self.selected = std.math.maxInt(usize);
                self.view.scroll.y = std.math.maxInt(usize);
            }

            if (key.matches('g', .{})) {
                self.selected = 0;
                self.view.scroll.y = 0;
            }
        }
    }

    pub fn draw(
        self: *List,
        parent: vaxis.Window,
        rows: usize,
        cols: usize,
    ) void {
        self.window = parent;

        self.view.draw(parent, .{
            .rows = rows,
            .cols = cols,
        });
    }
};

pub const logo =
    "Zig Music Player";
