const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const usb = @import("usb.zig");
const led = @import("led.zig");
const stdout = std.io.getStdOut().writer();

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    try usb.setup();
    usb.MP3_STATE.right.volume.on_update = change_volume;
    usb.ledOn(led.LED.RightAutoBeat);
    usb.ledOn(led.LED.RightHeadset);
    usb.ledOff(led.LED.RightHeadset);
    try usb.poll();
}

pub fn change_volume(_: u8, volume: u8) void {
    var volumePercent: u8 = @intCast(u8, (@intCast(u16, volume) * 100) / 256);
    const numberFmt = "{d}%";
    var number = allocator.alloc(u8, 8) catch return;
    var number2 = std.fmt.bufPrint(number[0..], numberFmt, .{volumePercent}) catch return;
    
    var command = [_][]const u8{"amixer", "-D", "pulse", "sset", "Master", number2};
    stdout.print("Got : {s}\n", .{number2}) catch return;

    var id = std.os.linux.fork();
    if (id == 0) {
        std.process.execv(allocator, command[0..]) catch return;
        std.process.exit(0);
    }
}
