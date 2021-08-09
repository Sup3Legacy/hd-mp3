const std = @import("std");
const testing = std.testing;
const usb = @import("usb.zig");
const led = @import("led.zig");
const stdout = std.io.getStdOut().writer();

pub fn main() !void {
    try usb.setup();
    usb.ledOn(led.LED.RightAutoBeat);
    usb.ledOn(led.LED.RightHeadset);
    usb.ledOff(led.LED.RightHeadset);
    while (true) {
        usb.ledOn(led.LED.RightHeadset);
        std.os.nanosleep(1, 0);
        usb.ledOff(led.LED.RightHeadset);
        std.os.nanosleep(1, 0);
    }
    try usb.poll();
}