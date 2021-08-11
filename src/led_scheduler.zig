const std = @import("std");
const led_src = @import("led.zig");
const priority_queue = @import("priority_queue.zig");

// Mailbox will be checked at least every MAX_INTERVAL ms.
const MAX_INTERVAL: usize = 100; 

const LedBlink = struct {
    offset: usize, // Note used anymore once enqueued
    up_time: usize, 
    down_time: usize,
    led: led_src.LED,
    state: bool,
};

const LedEvent = union {
    Blink: LebBlink,
    On: led_src.LED,
    Off: led_src.LED,
};

fn order(a: *usize, b: *usize) bool {
    return a.* < b.*;
}

const queueType = priority_queue.PriorityQueue(LedBlink, usize, 16, order);

const Queue = queueType.new();

pub fn ledScheduler() !void {
    var blink_enabled = [1]bool{false}**16;
    var on = [1]bool{false}**16;
    var off = [1]bool{false}**16;

    var timestamp = 0;

    // Main loop
    while (true) {
        // Fetch messages from mailbox

        // Loop while there are events to
        while (true) {
            if (Queue.peek()) |top| {
                var index = @enumToInt(top.led) - 1;

                // Blinking has been deactivated
                if (!blink_enabled[index]) {
                    _ = Queue.pop();
                    // Turn off the LED ?
                    continue;
                }
                var prio = try Queue.peek_priority();
                if (prio >= timestamp) { // Should be == in the future
                    var next_time = undefined;
                    if (top.state) {
                        next_time = top.down_time;
                    } else {
                        next_time = top.up_time;
                    }

                    // Handle LED logic

                    // Invert LED state in the queue
                    top.state = ~top.state;

                    Queue.update_priority(timestamp + next_time);
                }
            } else {
                std.os.nanosleep(0, MAX_INTERVAL * 1000);
            }
        }

        // handle new event.
    }
}