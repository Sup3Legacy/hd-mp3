const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub const LED = enum(u8) {
    LeftBeatLock = 1,
    RightBeatLock = 2,
    LeftFx = 3,
    RightFx = 4,
    RightCue = 5,
    RightCueButton = 6,
    RightPlay = 7,
    LeftCue = 8,
    LeftPlay = 9,
    LeftHeadset = 10,
    RightHeadset = 11,
    LeftCueButton = 12,
    LeftAutoBeat = 13,
    RightAutoBeat = 14,
    LeftLoop = 15,
    RightLoop = 16,
};

const LedState = packed struct {
    first: [8]bool,
    last: [8]bool,

    pub fn new() @This() {
        return LedState {
            .values = [_]bool{false} ** 16
        };
    }
};

pub fn ledToBytes(a: LED, p: *[2]u8) void {
    var i = @enumToInt(a) - 1;
    var unite: u8 = 1;
    //stdout.print("Got {}\n", .{i + 1}) catch return;
    if (i >= 8) {
        p[0] = 0;
        p[1] = unite << @intCast(u3, i - 8);
    } else {
        p[0] = unite << @intCast(u3, i);
        p[1] = 0;
    }
}