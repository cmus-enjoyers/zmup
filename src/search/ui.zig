const vaxis = @import("vaxis");
const std = @import("std");

pub fn draw(win: vaxis.Window, input: *vaxis.widgets.TextInput) void {
    const input_win = win.child(.{
        .x_off = win.width / 2 - 20,
        .y_off = win.height / 2 - 3,
        .width = .{ .limit = 40 },
        .height = .{ .limit = 3 },
        .border = .{
            .where = .all,
            .style = .{ .fg = .{ .index = 2 } },
        },
    });

    input.draw(input_win);
}
