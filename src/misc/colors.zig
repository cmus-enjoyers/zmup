const vaxis = @import("vaxis");

pub const white_rgb = .{ 255, 255, 255 };

pub const white_border: vaxis.Window.BorderOptions = .{
    .style = .{ .fg = .{ .rgb = white_rgb } },
    .where = .all,
};
