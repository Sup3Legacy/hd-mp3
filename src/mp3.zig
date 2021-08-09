const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn Component(comptime T: type) type {
    return struct {
        value: T,
        on_update: ?fn(T, T) void,

        pub fn update(this: *@This(), new_value: T) void {
            var old_value = this.value;
            this.value = new_value;

            if (old_value != new_value) {
                if(this.on_update) |func| {
                    func(old_value, new_value);
                    //var th = std.Thread.spawn(.{}, this.initThread, .{func, old_value, new_value}) catch return;
                    //th.join();
                }
            }
        }

        fn initThread(func: fn(T, T) void, old: T, new: T) void {
            func(old, new);
        }
    };
}

const ByteComponent = Component(u8);
const BoolComponent = Component(bool);

const Levels = struct {
    trebble: ByteComponent,
    medium: ByteComponent,
    bass: ByteComponent,
};

const Selector = struct {
    menu: BoolComponent,
    one: BoolComponent,
    two: BoolComponent,
    three: BoolComponent,
};

const Half = struct {
    jog: ByteComponent,
    play: BoolComponent,
    cue: BoolComponent,
    levels: Levels,
    volume: ByteComponent,
    pitch_plus: BoolComponent,
    pitch_minus: BoolComponent,
    track_next: BoolComponent,
    track_previous: BoolComponent,
    pitch: ByteComponent,
    headset: BoolComponent,
    auto_beat: BoolComponent,
    load: BoolComponent,
    beat_lock: BoolComponent,
    menu: Selector,
};

pub const Controller = struct {
    left: Half,
    right: Half,
    crossfader: ByteComponent,
    mouse_x: ByteComponent,
    mouse_y: ByteComponent,

    pub fn update(this: *Controller, buffer: *[20]u8) void {
        this.mouse_x.update(buffer[19]);
        this.mouse_y.update(buffer[18]);

        this.crossfader.update(buffer[11]);

        this.right.jog.update(buffer[17]);
        this.left.jog.update(buffer[16]);

        this.right.volume.update(buffer[13]);
        this.left.volume.update(buffer[12]);

        this.right.levels.bass.update(buffer[5]);
        this.right.levels.medium.update(buffer[6]);
        this.right.levels.trebble.update(buffer[7]);

        this.left.levels.bass.update(buffer[8]);
        this.left.levels.medium.update(buffer[9]);
        this.left.levels.trebble.update(buffer[10]);

        this.right.pitch.update(buffer[15]);
        this.right.pitch.update(buffer[14]);

        this.right.play.update(buffer[1] & 2 != 0);
        this.right.cue.update(buffer[1] & 4 != 0);
        this.right.track_next.update(buffer[1] & 32 != 0);
        this.right.track_previous.update(buffer[1] & 16 != 0);
        this.right.pitch_plus.update(buffer[3] & 64 != 0);
        this.right.pitch_minus.update(buffer[3] & 128 != 0);
        this.right.headset.update(buffer[4] & 1 != 0);
        this.right.auto_beat.update(buffer[1] & 8 != 0);
        this.right.load.update(buffer[4] & 8 != 0);
        this.right.beat_lock.update(buffer[4] & 2 != 0);
        this.right.menu.menu.update(buffer[1] & 1 != 0);
        this.right.menu.one.update(buffer[2] & 128 != 0);
        this.right.menu.two.update(buffer[3] & 1 != 0);
        this.right.menu.three.update(buffer[3] & 2 != 0);

        this.left.play.update(buffer[1] & 128 != 0);
        this.left.cue.update(buffer[2] & 1 != 0);
        this.left.track_next.update(buffer[2] & 8 != 0);
        this.left.track_previous.update(buffer[2] & 4 != 0);
        this.left.pitch_plus.update(buffer[3] & 4 != 0);
        this.left.pitch_minus.update(buffer[3] & 8 != 0);
        this.left.headset.update(buffer[3] & 16 != 0);
        this.left.auto_beat.update(buffer[2] & 2 != 0);
        this.left.load.update(buffer[4] & 4 != 0);
        this.left.beat_lock.update(buffer[3] & 32 != 0);
        this.left.menu.menu.update(buffer[1] & 64 != 0);
        this.left.menu.one.update(buffer[2] & 64 != 0);
        this.left.menu.two.update(buffer[2] & 32 != 0);
        this.left.menu.three.update(buffer[2] & 16 != 0);
    }
};

