const std = @import("std");
const vaxis = @import("vaxis");

pub const Test = struct {
    first: []const u8,
};

pub fn drawSimpleTable(allocator: std.mem.Allocator, win: vaxis.Window) !void {
    const active_bg: vaxis.Cell.Color = .{ .rgb = .{ 0, 0, 0 } };
    const selected_bg: vaxis.Cell.Color = .{ .rgb = .{ 0, 0, 0 } };

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

pub fn drawText(win: vaxis.Window, text: []const u8, x_offset: usize, y_offset: usize) !void {
    const style: vaxis.Style = .{ .fg = .{
        .rgb = .{255} ** 3,
    } };

    const segment: vaxis.Segment = .{ .text = text, .style = style };

    _ = try win.printSegment(segment, .{ .row_offset = y_offset, .col_offset = x_offset });
}
