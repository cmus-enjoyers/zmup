const vaxis = @import("vaxis");
const std = @import("std");

pub fn input(key: vaxis.Key, view: *vaxis.widgets.ScrollView) void {
    if (key.matches('j', .{})) {
        view.scroll.y +|= 1;
    }

    if (key.matches('k', .{})) {
        view.scroll.y -|= 1;
    }

    if (key.matches('G', .{})) {
        view.scroll.y = std.math.maxInt(usize);
    }

    if (key.matches('g', .{})) {
        view.scroll.y = 0;
    }
}
