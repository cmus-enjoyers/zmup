const vaxis = @import("vaxis");
const std = @import("std");

pub const List = struct {
    view: *vaxis.widgets.ScrollView,
    selected: usize = 0,
    window: ?vaxis.Window = null,
    rows: ?usize = null,

    pub fn input(self: *List, key: vaxis.Key) void {
        if (self.window) |value| {
            if (key.matches('j', .{})) {
                if (self.selected < self.rows.? - 1) {
                    self.selected +|= 1;
                }

                if (self.selected >= self.view.scroll.y + value.height - 2) {
                    self.view.scroll.y +|= 1;
                }
            }

            if (key.matches('k', .{})) {
                if (self.selected > 0) {
                    self.selected -|= 1;
                }

                if (self.selected <= self.view.scroll.y + 1) {
                    self.view.scroll.y -|= 1;
                }
            }

            if (key.matches('G', .{})) {
                self.selected = self.rows.? - 1;
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
        self.rows = rows;

        self.view.draw(parent, .{
            .rows = rows,
            .cols = cols,
        });
    }
};
