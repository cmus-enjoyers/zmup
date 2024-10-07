const vaxis = @import("vaxis");
const List = @import("../ui/ui.zig").List;
const std = @import("std");

pub fn input(key: vaxis.Key, list: *List) void {
    if (key.matches('j', .{})) {
        list.view.scroll.y +|= 1;
    }

    if (key.matches('k', .{})) {
        list.view.scroll.y -|= 1;
    }

    if (key.matches('G', .{})) {
        list.view.scroll.y = std.math.maxInt(usize);
    }

    if (key.matches('g', .{})) {
        list.view.scroll.y = 0;
    }
}
