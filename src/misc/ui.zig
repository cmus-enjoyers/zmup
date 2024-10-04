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

pub fn drawPlaylistWin(parent: Window, part: usize) Window {
    return parent.child(.{
        .border = white_border,
        .width = .{ .limit = parent.width / part },
        .height = .{ .limit = parent.height },
    });
}

pub fn drawMusicWin(parent: Window, off: usize) Window {
    return parent.child(.{
        .border = white_border,
        .x_off = off,
    });
}
