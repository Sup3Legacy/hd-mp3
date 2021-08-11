const std = @import("std");
const led_src = @import("led.zig");
const priority_queue = @import("priority_queue.zig");
const com_queue = @import("com_queue.zig");

// Mailbox will be checked at least every MAX_INTERVAL ms.
const MAX_INTERVAL: usize = 100; 

const LedBlink = struct {
    offset: usize, // Note used anymore once enqueued
    up_time: usize, 
    down_time: usize,
    led: led_src.LED,
    state: bool,
};

const LedEventEnum = enum  {
    Blink,
    On,
    Off,
};

const LedEvent = union(LedEventEnum) {
    Blink: LedBlink,
    On: led_src.LED,
    Off: led_src.LED,
};

fn order(a: *usize, b: *usize) bool {
    return a.* < b.*;
}

const queueType = priority_queue.PriorityQueue(LedBlink, usize, 16, order);

var Queue = queueType.new();

var ComQueue = com_queue.ComQueue(LedEvent, 64).new();

pub fn ledScheduler() !void {
    var blink_enabled = [1]bool{false}**16;
    var on = [1]bool{false}**16;
    var off = [1]bool{true}**16;

    var timestamp: usize = 0;

    // Main loop
    while (true) {
        // Fetch messages from mailbox
        while (!ComQueue.is_empty()) {
            var new_packet = try ComQueue.pop();
            switch (new_packet) {
                LedEvent.Blink => |BlinkPacket| {
                    var index = @enumToInt(BlinkPacket.led) - 1;
                    if (!blink_enabled[index]) {
                        try Queue.enqueue(BlinkPacket, timestamp + BlinkPacket.offset);
                        on[index] = false;
                        off[index] = false;
                    }
                },
                LedEvent.On => |led| {
                    var index = @enumToInt(led) - 1;
                    blink_enabled[index] = false;
                    on[index] = true;
                    off[index] = false;
                },
                LedEvent.Off => |led| {
                    var index = @enumToInt(led) - 1;
                    blink_enabled[index] = false;
                    on[index] = false;
                    off[index] = true;
                },
            }
        }

        var next_time = MAX_INTERVAL;
        // Loop while there are events to
        while (true) {
            var top = Queue.peek() catch break;
                var index = @enumToInt(top.led) - 1;

                // Blinking has been deactivated
                if (!blink_enabled[index]) {
                    _ = try Queue.pop();
                    // Turn off the LED ?
                    continue;
                }
                var prio = try Queue.peek_priority();
                if (prio.* <= timestamp) { // Should be == in the future
                    var local_next_time: usize = 0;
                    if (top.state) {
                        local_next_time = top.down_time;
                    } else {
                        local_next_time = top.up_time;
                    }

                    if (next_time > local_next_time) {
                        next_time = local_next_time;
                    }

                    // Handle LED logic

                    // Invert LED state in the queue
                    top.state = !top.state;

                    try Queue.update_priority(timestamp + local_next_time);
                } else {
                    // No more event to be handled
                    break;
                }
        }
            
        var next_time_corrected = @minimum(MAX_INTERVAL * 1000, next_time);
        timestamp += next_time_corrected;
        std.os.nanosleep(0, next_time_corrected);
    }
}