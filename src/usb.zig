const c = @cImport({
    @cInclude("hidapi/hidapi.h");
});

const std = @import("std");
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;

const Device = struct {
    product_id: u16,
    interface_number: u8,
    ep_in: u8,
    ep_out: u8,
    ep_in2: u8,
    interface_number2: u8,
};

const HERCULES_MP3 = Device { .product_id = 0xd001, .interface_number = 2, .ep_in = 0x83, .ep_out = 0x01, .ep_in2 = 0, .interface_number2 = 4 };

const HERCULES_VENDOR_ID: u16 = 0x06f8;

var HID_DEVICE: c.hid_device = undefined;

const MAX_STR: c_int = 255;

pub fn setup() !void {
    var str: [4 * MAX_STR:0]u8 align(4) = undefined;
    var buffer: [65]u8 = undefined;
    
    var res = c.hid_init();
    try stdout.print("Got res : {x}\n", .{@intCast(usize, res)});
    var handle = c.hid_open(0x06f8, 0xd001, null);

    try stdout.print("Ousp {}\n", .{handle});

    res = c.hid_get_manufacturer_string(handle, @ptrCast([*c]c_int, &str), MAX_STR);

    try stdout.print("Aïe.\n", .{});
    try stdout.print("Device manufacturer : {s}\n", .{str});

    res = c.hid_get_product_string(handle, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device profuct : {s}\n", .{str});

    res = c.hid_get_serial_number_string(handle, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device serial number : {s}\n", .{str});

    res = c.hid_get_indexed_string(handle, 1, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device indexed string 1 : {s}\n", .{str});
    
    while (true) {
        // Read requested state
        res = c.hid_read(handle, @ptrCast([*c] u8, &buffer), 65);

        // Print out the returned buffer.
        if (res > 0) {
            try stdout.print("res : {}. Got bytes :", .{res});
            var i: usize = 0;
            while (i < res) : (i += 1) {
                try stdout.print(" {b:0>8}", .{buffer[i]});
            }
            try stdout.print("\n", .{});
        }
    }
}