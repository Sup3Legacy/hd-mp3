const c = @cImport({
    @cInclude("hidapi/hidapi.h");
});

const std = @import("std");
const stdout = std.io.getStdOut().writer();
var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
const allocator = &arena.allocator;
const mem = std.mem;
const mp3 = @import("mp3.zig");

var HID_DEVICE: c.hid_device = undefined;

const MAX_STR: c_int = 255;

var MP3_STATE: mp3.Controller = undefined;

var HANDLE: ?*c.struct_hid_device_ = undefined;

pub fn setup() !void {
    var str: [4 * MAX_STR:0]u8 align(4) = undefined;
    
    var res = c.hid_init();
    HANDLE = c.hid_open(0x06f8, 0xd001, null);

    res = c.hid_get_manufacturer_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device manufacturer : {s}\n", .{str});

    res = c.hid_get_product_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device profuct : {s}\n", .{str});

    res = c.hid_get_serial_number_string(HANDLE, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device serial number : {s}\n", .{str});

    res = c.hid_get_indexed_string(HANDLE, 1, @ptrCast([*c]c_int, &str), MAX_STR);
    try stdout.print("Device indexed string 1 : {s}\n", .{str});

    //res = c.hid_set_nonblocking(HANDLE, 1);
}

pub fn poll() !void {
    var buffer: [2][20]u8 = undefined;
    var buffer_index: usize = 0;

    while (true) {
        // Read requested state
        res = c.hid_read(HANDLE, @ptrCast([*c] u8, &(buffer[buffer_index])), 20);

        // Print out the returned buffer.
        if (res > 0 and !mem.eql(u8, &buffer[buffer_index], &buffer[1 - buffer_index])) {
            try stdout.print("res : {}. Got bytes :", .{res});
            var i: usize = 0;
            while (i < res) : (i += 1) {
                try stdout.print(" {d:0>8}", .{buffer[buffer_index][i]});
            }
            try stdout.print("\n", .{});
            MP3_STATE.update(&buffer[buffer_index]);
        }

        buffer_index = 1 - buffer_index;
    }
}