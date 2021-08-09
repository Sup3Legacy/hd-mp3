const std = @import("std");
const testing = std.testing;
const usb = @import("usb.zig");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try usb.setup();
    try usb.testing();
    //try usb.poll();
}