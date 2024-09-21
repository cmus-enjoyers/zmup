const std = @import("std");
const vaxis = @import("vaxis");

pub const Test = struct {
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
