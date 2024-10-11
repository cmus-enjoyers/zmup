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

pub const green_index = 2;
pub const white_index = 255;
pub const black_index = 0;

pub const green_border: vaxis.Window.BorderOptions = .{
    .style = .{ .fg = .{ .index = green_index } },
    .where = .all,
};

pub const white_border: vaxis.Window.BorderOptions = .{
    .style = .{ .fg = .{ .rgb = white_rgb } },
    .where = .all,
};

pub const selected_item_style: vaxis.Style = .{
    .italic = true,
    .bg = .{
        .index = white_index,
    },
    .fg = .{
        .index = black_index,
    },
};

pub fn style_list_item(is_selected: bool) vaxis.Style {
    return if (is_selected == true) selected_item_style else undefined;
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

pub const logo =
    "Zig Music Player";
