const vaxis = @import("vaxis");
const std = @import("std");

pub fn isCtrlE(key: vaxis.Key) bool {
    return key.matches('e', .{ .ctrl = true });
}

pub fn isCtrlY(key: vaxis.Key) bool {
    return key.matches('y', .{ .ctrl = true });
}

pub fn isCtrlD(key: vaxis.Key) bool {
    return key.matches('d', .{ .ctrl = true });
}

pub fn isCtrlU(key: vaxis.Key) bool {
    return key.matches('u', .{ .ctrl = true });
}

pub fn windowGetHalfHeight(window: vaxis.Window) usize {
    return @divFloor(window.height, 2);
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

    pub fn updateScrollAndSelected(self: *List, selected: usize, scroll: usize) void {
        self.selected = selected;
        self.view.scroll.y = scroll;
    }

    pub fn substrate(self: *List, by: usize) void {
        self.view.scroll.y -|= by;
        self.selected -|= by;
    }

    pub fn add(self: *List, by: usize) void {
        self.view.scroll.y += by;
        self.selected += by;
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

            if (isCtrlY(key)) {
                self.view.scroll.y -|= 1;
                self.selected -|= 1;
            }

            if (isCtrlD(key)) {
                self.add(windowGetHalfHeight(self.window.?));
            }

            if (isCtrlU(key)) {
                self.substrate(windowGetHalfHeight(self.window.?));
            }

            if (key.matches('G', .{})) {
                self.updateScrollAndSelected(self.rows.? - 1, std.math.maxInt(usize));
            }

            if (key.matches('g', .{})) {
                self.updateScrollAndSelected(0, 0);
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

        self.clamp();
        self.view.draw(parent, .{
            .rows = rows,
            .cols = cols,
        });
    }
};
// {{{
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
} // }}}
