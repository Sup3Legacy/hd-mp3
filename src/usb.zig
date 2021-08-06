const c = @cImport({
    @cInclude("/usr/include/libusb-1.0/libusb.h");
    @cInclude("poll.h");
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

var context: ?*(c.libusb_context) = null;

var usb_device: ?*c.libusb_device_handle = null;

var fds: ?[*c][*c]const c.libusb_pollfd = null;

pub fn usb_setup(name: [*]u8, namelen: usize) !isize {
    var ret: c_int = c.libusb_init(&context);
    if (namelen == 0) {
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
        return -1;
    }

    var index: usize = 0;

    var hercules_device: c.libusb_device_descriptor = undefined;

    while (index < count) {
        var device = devs[index];
        var device_descriptor: c.libusb_device_descriptor = undefined;
        var dev = c.libusb_get_device_descriptor(device, &device_descriptor);
        if (dev != 0) {
            try stdout.print("Could not get devide decriptor at index {}", .{index});
        }

        try stdout.print("Device info {x:0>4.4}:{x:0>4.4} \n", .{device_descriptor.idVendor, device_descriptor.idProduct});

        if (device_descriptor.idVendor == HERCULES_VENDOR_ID) {
            try stdout.print("Found Hercules device.\n", .{});
            hercules_device = device_descriptor;
        }

        index += 1;
    }
    c.libusb_free_device_list(devs, 1);

    // Needed permission. New file in /etc/udev/rules.d/ with content
    // `UBSYSTEM=="usb", ATTR{idVendor}=="06f8", ATTR{idProduct}=="d001", MODE="0666"`
    // Then `udevadm control -R`
    usb_device = c.libusb_open_device_with_vid_pid(context, HERCULES_VENDOR_ID, HERCULES_MP3.product_id);

    try stdout.print("Hercules device : {s}\n", .{usb_device});

    var ddesc: c.libusb_device_descriptor = undefined;

    @"_" = c.libusb_get_device_descriptor(c.libusb_get_device(usb_device), &ddesc);
    var string_ret = c.libusb_get_string_descriptor_ascii(usb_device, ddesc.iManufacturer, @as([*c]u8, name), @intCast(c_int, namelen));

    if (string_ret > 0) {
        name[@intCast(usize, string_ret)] = ' ';
        string_ret = c.libusb_get_string_descriptor_ascii(usb_device, ddesc.iProduct, @intToPtr([*c]u8, @ptrToInt(name) + @intCast(usize, string_ret) + 1), @intCast(c_int, namelen) - string_ret - 1);
    }

    if (string_ret < 0) {
        try stdout.print("WTF", .{});
    }

    try stdout.print("Found device with name : {s}\n", .{@ptrCast([*:0]u8, name)});

    var claim_ret = c.libusb_claim_interface(usb_device, HERCULES_MP3.interface_number);

    if (claim_ret == 0) {
        try initiate_transfer();
        if (HERCULES_MP3.ep_in2 != 0) {
            var lol = c.libusb_claim_interface(usb_device, HERCULES_MP3.interface_number2);
            if (lol < 0) {
                try stdout.print("Could not claim additional interface {}. {s}\n{s}\n", .{HERCULES_MP3.interface_number2, c.libusb_error_name(lol), c.libusb_strerror(lol)});
                return -1;
            }
            try initiate_transfer_additional();
        }
        return 0;
    } else {
        try stdout.print("Could not claim interface {}. {s}\n{s}\n", .{HERCULES_MP3.interface_number, c.libusb_error_name(claim_ret), c.libusb_strerror(claim_ret)});
        return -1;
    }

    return count;
}

pub fn initiate_transfer() !void {
    try stdout.print("Initiated transaction.\n", .{});
    const buffer_size: usize = 256;
    var buffer = try allocator.alloc(u8, buffer_size);

    var xfer_in = c.libusb_alloc_transfer(0);

    xfer_in.*.timeout = 1000;
    xfer_in.*.flags = @as(u8, xfer_in.*.flags) | @as(u8, c.LIBUSB_TRANSFER_ADD_ZERO_PACKET);
    c.libusb_fill_bulk_transfer(xfer_in, usb_device, HERCULES_MP3.ep_in, @ptrCast([*c]u8, buffer), buffer_size, xfer_transfer_done, null, 0);
    _ = c.libusb_submit_transfer(xfer_in);
}

fn xfer_transfer_done(xfer: [*c]c.libusb_transfer) callconv(.C) void {
    var data = xfer.*.buffer;
    var datalen = xfer.*.actual_length;
    stdout.print("Haha\n", .{}) catch return;
    if (xfer.*.status == c.LIBUSB_TRANSFER_COMPLETED) {
        stdout.print("Hihi\n", .{}) catch return;
        stdout.print("Receiving data : {s} with length {}", .{@ptrCast(*[256]u8, data), datalen}) catch return;
    } else {
        stdout.print("Ousp\n", .{}) catch return;
    }

    allocator.destroy(data);
    c.libusb_free_transfer(xfer);
}

pub fn initiate_transfer_additional() !void {
    const buffer_size: usize = 256;
    var buffer = try allocator.alloc(u8, buffer_size);

    var xfer_in = c.libusb_alloc_transfer(0);

    xfer_in.*.timeout = 1000;
    xfer_in.*.flags = @as(u8, xfer_in.*.flags) | @as(u8, c.LIBUSB_TRANSFER_ADD_ZERO_PACKET);
    c.libusb_fill_bulk_transfer(xfer_in, usb_device, HERCULES_MP3.ep_in2, @ptrCast([*c]u8, buffer), buffer_size, xfer_transfer_done_additional, null, 0);
    _ = c.libusb_submit_transfer(xfer_in);
}

fn xfer_transfer_done_additional(xfer: [*c]c.libusb_transfer) callconv(.C) void {
    var data = xfer.*.buffer;
    var datalen = xfer.*.actual_length;
    stdout.print("Haha\n", .{}) catch return;
    if (xfer.*.status == c.LIBUSB_TRANSFER_COMPLETED) {
        stdout.print("Hihi\n", .{}) catch return;
        stdout.print("Receiving data : {s} with length {}", .{@ptrCast(*[256]u8, data), datalen}) catch return;
    } else {
        stdout.print("Ousp\n", .{}) catch return;
    }

    allocator.destroy(data);
    c.libusb_free_transfer(xfer);
}

pub fn write(data: []u8) !void {
    try stdout.print("Héhéhé\n", .{});
    var xfer = c.libusb_alloc_transfer(0);
    xfer.*.timeout = 1000;
    var buffer = try allocator.alloc(u8, data.len);
    // Better with memcpy
    var index: usize = 0;
    while (index < data.len) {
        buffer[index] = data[index];
        index += 1;
    }
    c.libusb_fill_bulk_transfer(xfer, usb_device, HERCULES_MP3.ep_out, @ptrCast([*c]u8, buffer), @intCast(c_int, data.len), write_done, null, 0);
    _ = c.libusb_submit_transfer(xfer);
}

pub fn write_done(xfer: [*c]c.libusb_transfer) callconv(.C) void {
    if (xfer.*.status == c.LIBUSB_TRANSFER_TIMED_OUT) {
        stdout.print("Times out.", .{}) catch return;
    } else if (xfer.*.status != 0 and xfer.*.status != c.LIBUSB_TRANSFER_CANCELLED) {
        stdout.print("USB write status {d}", .{xfer.*.status}) catch return;
    }

    allocator.destroy(xfer.*.buffer);
    c.libusb_free_transfer(xfer);
}

pub fn fd_setup(nfds: *usize) void {
    fds = c.libusb_get_pollfds(context);
    if (fds == null) {
        stdout.print("Could not retreive fds. \n", .{}) catch return;
    }

    var index: usize = 0;

    while (true) {
        if (fds.?[index] == null) {
            break;
        }
        var fd = fds.?[index].*;

        if (fd.fd > nfds.*) {
            nfds.* = @intCast(usize, fd.fd);
        }

        if (fd.events & c.POLLIN != 0) {
            _ = c.libusb_handle_events(context);
            stdout.print("Got IN packet\n", .{}) catch return;
        }

        if (fd.events & c.POLLOUT != 0) {
            _ = c.libusb_handle_events(context);
            stdout.print("Got OUT packet\n", .{}) catch return;
        }

        index += 1;
    }
}

pub fn main_loop() void {

    while (true) {
        var nfds : usize = 0;

        fd_setup(&nfds);
    }
}