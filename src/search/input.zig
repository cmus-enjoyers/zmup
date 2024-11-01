const std = @import("std");
const vaxis = @import("vaxis");

const TextInput = vaxis.widgets.TextInput;
const Unicode = vaxis.Unicode;

pub fn createSearchInput(allocator: std.mem.Allocator, ptr: *?TextInput, unicode: *Unicode) void {
    ptr.* = TextInput.init(allocator, unicode);
}
