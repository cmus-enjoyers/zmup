const std = @import("std");
const List = @import("../components/list.zig").List;
const validateScrollingKey = @import("../components/list.zig").validateScrollingKey;
const vaxis = @import("vaxis");
const Playlist = @import("../playlists/playlists.zig").Playlist;

pub fn input(key: vaxis.Key, selected_view: *List, music_list: *List, selected_playlist: *Playlist, height: usize) !void {
    if (std.meta.eql(selected_view, music_list)) {
        switch (validateScrollingKey(key)) {
            .G => {
                try selected_playlist.continueLoading(std.math.maxInt(usize));
                music_list.setRows(selected_playlist.content.?.items.len);
            },
            .None => {},
            else => try selected_playlist.continueLoading(height),
        }
    }
}
