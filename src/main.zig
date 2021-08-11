const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const usb = @import("usb.zig");
const led = @import("led.zig");
const led_scheduler = @import("led_scheduler.zig");
const priority_queue = @import("priority_queue.zig");
const stdout = std.io.getStdOut().writer();

var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

pub fn main() !void {
    try usb.setup();
    _ = try std.Thread.spawn(.{},led_scheduler.ledScheduler, .{});
    try led_scheduler.ComQueue.push(led_scheduler.LedEvent {
        .Blink = led_scheduler.LedBlink {
            .offset = 0,
            .up_time = 500,
            .down_time = 500,
            .state = false,
            .led = led.LED.RightHeadset,
        } 
        });
    try led_scheduler.ComQueue.push(led_scheduler.LedEvent {
        .Blink = led_scheduler.LedBlink {
            .offset = 0,
            .up_time = 250,
            .down_time = 250,
            .state = false,
            .led = led.LED.LeftHeadset,
        } 
        });
    try led_scheduler.ComQueue.push(led_scheduler.LedEvent {
        .Blink = led_scheduler.LedBlink {
            .offset = 10000,
            .up_time = 1000,
            .down_time = 300,
            .state = false,
            .led = led.LED.RightFx,
        } 
        });
    while (true) {
        std.os.nanosleep(10, 0);
    }
    return;
    
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

pub fn lol(a: *usize, b: *usize) bool {
    return a.* < b.*;
}

test "priority" {
    const pqt = priority_queue.PriorityQueue(usize, usize, 42, lol);
    var pq: pqt = pqt.new();
    try pq.enqueue(42, 3);
    try pq.enqueue(69, 0);
    try pq.enqueue(420, 1);
    try pq.enqueue(123, 4);
    
    try stdout.print("Got {d}\n", .{pq.peek()});
}