const vaxis = @import("vaxis");
const std = @import("std");

pub fn isCtrlE(key: vaxis.Key) bool {
    return key.matches('e', .{ .ctrl = true });
}

pub fn isCtrlU(key: vaxis.Key) bool {
    return key.matches('u', .{ .ctrl = true });
}

pub const List = struct {
    view: *vaxis.widgets.ScrollView,
    selected: usize = 0,
    window: ?vaxis.Window = null,
    rows: ?usize = null,

    pub fn clamp(self: *List) void {
        if (self.rows) |rows| {
            if (self.selected >= rows) {
                self.selected = rows - 1;
            }

            if (self.selected < 0) {
                self.selected = 0;
            }
        }
    }

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

                if (self.selected <= self.view.scroll.y + 1) {
                    self.view.scroll.y -|= 1;
                }
            }

            if (isCtrlE(key)) {
                self.view.scroll.y += 1;
                self.selected += 1;
            }

            if (isCtrlU(key)) {
                self.view.scroll.y -= 1;
                self.selected -= 1;
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

    pub fn setRows(self: *List, rows: usize) void {
        self.rows = rows;
        // TODO: maybe come up with something better
    }

    pub fn draw(
        self: *List,
        parent: vaxis.Window,
        rows: usize,
        cols: usize,
    ) void {
        self.window = parent;
        self.rows = rows;

        self.clamp();
        self.view.draw(parent, .{
            .rows = rows,
            .cols = cols,
        });
    }
};

pub fn isScrollingKey(key: vaxis.Key) bool {
    return key.matches('j', .{}) or key.matches('k', .{}) or key.matches('G', .{}) or key.matches('g', .{});
}

const ScrollingKey = enum {
    j,
    k,
    g,
    G,
    None,
};

pub fn validateScrollingKey(key: vaxis.Key) ScrollingKey {
    if (key.matches('j', .{})) {
        return ScrollingKey.j;
    }

    if (key.matches('k', .{})) {
        return ScrollingKey.k;
    }

    if (key.matches('g', .{})) {
        return ScrollingKey.g;
    }

    if (key.matches('G', .{})) {
        return ScrollingKey.G;
    }

    return ScrollingKey.None;
}
