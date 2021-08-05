const c = @cImport({
    @cInclude("/usr/include/libusb-1.0/libusb.h");
});

const std = @import("std");
const stdout = std.io.getStdOut().writer();

const Device = struct {
    product_id: u16,
    interface_number: u8,
    ep_in: u8,
    ep_out: u8,
    ep_in2: u8,
    interface_number2: u8,
};

var context: ?*(c.libusb_context) = null;

pub fn usb_setup(name: []u8, namelen: usize) !isize {
    var ret: c_int = c.libusb_init(&context);
    if (namelen == 0 or name.len == 0) {
        return -2;
    }
    if (ret < 0) {
        return -1;
    }
    if (c.libusb_pollfds_handle_timeouts(context) == 0) {
        return -1;
    }
    var devs: [*c]?*c.libusb_device = undefined;
    try stdout.print("Locating Hercules USB devices\n", .{});
    var count = c.libusb_get_device_list(context, &devs);

    if (count == 0) {
        try stdout.print("Could not get any USB device.\n", .{});
    } else if (count < 0) {
        try stdout.print("Error in device fetch : {s} {s}\n", .{c.libusb_error_name(@intCast(c_int, count)), c.libusb_strerror(@intCast(c_int, count))});
    }

    var index: usize = 0;

    while (index < count) {
        var device = devs[index];
        var device_descriptor: c.libusb_device_descriptor = undefined;
        var dev = c.libusb_get_device_descriptor(device, &device_descriptor);
        if (dev != 0) {
            try stdout.print("Could not get devide decriptor at index {}", .{index});
        }

        index += 1;
    }

    return count;
}