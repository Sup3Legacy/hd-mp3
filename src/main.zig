const std = @import("std");
const testing = std.testing;
const usb = @import("usb.zig");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    var hihi: [100]u8 = undefined;
    var res = usb.usb_setup(&hihi, 100);
    try stdout.print("Returned {d}\n", .{res});

    usb.main_loop();
}