const led_src = @import("led.zig");

const LedEvent = struct {
    offset: usize, // Note used anymore once enqueued
    uptime: usize, 
    downtime: usize,
    led: led_src.LED
};

pub fn ledScheduler() !void {
    while (true) {
        // Fetch messages from mailbox

        // Update current event priority.

        // handle new event.
    }
}