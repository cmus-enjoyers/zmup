debug(vaxis): resizing screen: width=208 height=40
thread 29614 panic: integer overflow
/home/vktrenokh/Documents/zmup/src/components/list.zig:13:49: 0x1083fd6 in input (zmup)
                if (self.selected < self.rows.? - 1) {
                                                ^
/home/vktrenokh/Documents/zmup/src/main.zig:94:36: 0x1082f29 in main (zmup)
                selected_view.input(key);
                                   ^
/usr/lib/zig/std/start.zig:524:37: 0x1084b1e in main (zmup)
            const result = root.main() catch |err| {
                                    ^
???:?:?: 0x7ae9fd037d6d in ??? (libc.so.6)
Unwind information for `libc.so.6:0x7ae9fd037d6d` was not available, trace may be incomplete

