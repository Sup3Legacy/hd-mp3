const c = @cImport({
    @cInclude("hidapi/hidapi.h");
});

const std = @import("std");
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;
const mem = std.mem;
const mp3 = @import("mp3.zig");
const led = @import("led.zig");

var HID_DEVICE: c.hid_device = undefined;

const MAX_STR: c_int = 255;

pub var MP3_STATE: mp3.Controller = undefined;
var LED_STATE = led.LedState.new();

var HANDLE: ?*c.struct_hid_device_ = undefined;

var LED_BUFFER = [3]u8{0x01, 0, 0};

const HID_ERROR = error {
    INIT_FAILED,
    DEVICE_UNAVAILABLE,
};

pub fn setup() !void {
    var str: [4 * MAX_STR:0]u8 align(4) = undefined;
    
    var res = c.hid_init();

    if (res < 0) {
        return HID_ERROR.INIT_FAILED;
    }

    HANDLE = c.hid_open(0x06f8, 0xd001, null);

    if (HANDLE == null) {
        return HID_ERROR.DEVICE_UNAVAILABLE;
    }

    res = c.hid_get_manufacturer_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device manufacturer : {s}\n", .{str});

    res = c.hid_get_product_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device profuct : {s}\n", .{str});

    res = c.hid_get_serial_number_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device serial number : {s}\n", .{str});

    res = c.hid_get_indexed_string(HANDLE, 1, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device indexed string 1 : {s}\n", .{str});

    res = c.hid_set_nonblocking(HANDLE, 1);
}

pub fn poll() !void {
    var buffer: [2][20]u8 = undefined;
    var buffer_index: usize = 0;

    while (true) {
        var res = c.hid_read(HANDLE, @ptrCast([*c] u8, &(buffer[buffer_index])), 20);

        if (res > 0) {
            while (res != 0) {
                res = c.hid_read(HANDLE, @ptrCast([*c] u8, &(buffer[buffer_index])), 20);
            }
            if (!mem.eql(u8, &buffer[buffer_index], &buffer[1 - buffer_index])) {
                try stdout.print("res : {}. Got bytes :", .{res});
                var i: usize = 0;
                while (i < 20) : (i += 1) {
                    try stdout.print(" {d:0>3}", .{buffer[buffer_index][i]});
                }
                try stdout.print("\n", .{});
                MP3_STATE.update(&buffer[buffer_index]);
            }
        }

        buffer_index = 1 - buffer_index;
        std.os.nanosleep(0, 10000000);
    }
}

pub fn testing() !void {
    var buffer: [3]u8 = undefined;

    var index: usize = 0;
    while (index < 3) : (index += 1) {
        buffer[index] = 0;
    }

    buffer[0] = 0x01;
    buffer[1] = 0b00000000;
    buffer[2] = 0b00000000;
    
    _ = c.hid_write(HANDLE, @ptrCast([*c] u8, &buffer), 3);
}

pub fn ledOn(ledArg: led.LED) void {
    var bytes = [2]u8{0, 0};
    led.ledToBytes(ledArg, &bytes);
    LED_BUFFER[1] |= bytes[0];
    LED_BUFFER[2] |= bytes[1];
    //ledUpdate();
}

pub fn ledOff(ledArg: led.LED) void {
    var bytes = [2]u8{0, 0};
    led.ledToBytes(ledArg, &bytes);
    LED_BUFFER[1] &= ~bytes[0];
    LED_BUFFER[2] &= ~bytes[1];
    //ledUpdate();
}

pub fn ledUpdate() void {
    LED_BUFFER[0] = 0x01;
    _ = c.hid_write(HANDLE, @ptrCast([*c] u8, &LED_BUFFER), 3);
}
