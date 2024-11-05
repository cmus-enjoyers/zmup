const std = @import("std");
const Playlist = @import("../playlists/playlists.zig").Playlist;
const vaxis = @import("vaxis");

const TextInput = vaxis.widgets.TextInput;
const Unicode = vaxis.Unicode;

pub fn search(allocator: std.mem.Allocator, list: *std.ArrayList(*Playlist), string: []const u8) !std.ArrayList(usize) {
    var indicies = std.ArrayList(usize).init(allocator);

    for (list.items, 0..) |item, i| {
        if (std.ascii.indexOfIgnoreCasePos(item.name, 0, string) != null) {
            try indicies.append(i);
        }
    }

    return indicies;
}

pub fn createTextInput(allocator: std.mem.Allocator, ptr: *?TextInput, unicode: *Unicode) void {
    ptr.* = TextInput.init(allocator, unicode);
}
