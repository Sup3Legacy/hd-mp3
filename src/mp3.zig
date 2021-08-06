
const Levels = struct {
    trebble: u8,
    medium: u8,
    bass: u8,
};

const Selector = struct {
    menu: bool,
    one: bool,
    two: bool,
    three: bool,
};

const Half = struct {
    jog: u8,
    play: bool,
    cue: bool,
    levels: Levels,
    volume: u8,
    pitch_plus: bool,
    pitch_minus: bool,
    track_next: bool,
    track_previous: bool,
    pitch: u8,
    headset: bool,
    auto_beat: bool,
    load: bool,
    beat_lock: bool,
    menu: Selector,
};

pub const Controller = struct {
    left: Half,
    right: Half,
    crossfader: u8,
    mouse_x: u8,
    mouse_y: u8,

    pub fn update(this: *Controller, buffer: *[20]u8) void {
        this.mouse_x = buffer[19];
        this.mouse_y = buffer[18];

        this.crossfader = buffer[11];

        this.right.jog = buffer[17];
        this.left.jog = buffer[16];

        this.right.volume = buffer[13];
        this.left.volume = buffer[12];

        this.right.levels.bass = buffer[5];
        this.right.levels.medium = buffer[6];
        this.right.levels.trebble = buffer[7];

        this.left.levels.bass = buffer[8];
        this.left.levels.medium = buffer[9];
        this.left.levels.trebble = buffer[10];

        this.right.pitch = buffer[15];
        this.right.pitch = buffer[14];

        this.right.play = buffer[1] & 2 != 0;
        this.right.cue = buffer[1] & 4 != 0;
        this.right.track_next = buffer[1] & 32 != 0;
        this.right.track_previous = buffer[1] & 16 != 0;
        this.right.pitch_plus = buffer[3] & 64 != 0;
        this.right.pitch_minus = buffer[3] & 128 != 0;
        this.right.headset = buffer[4] & 1 != 0;
        this.right.auto_beat = buffer[1] & 8 != 0;
        this.right.load = buffer[4] & 8 != 0;
        this.right.beat_lock = buffer[4] & 2 != 0;
        this.right.menu.menu = buffer[1] & 1 != 0;
        this.right.menu.one = buffer[2] & 128 != 0;
        this.right.menu.two = buffer[3] & 1 != 0;
        this.right.menu.three = buffer[3] & 2 != 0;

        this.left.play = buffer[1] & 128 != 0;
        this.left.cue = buffer[2] & 1 != 0;
        this.left.track_next = buffer[2] & 8 != 0;
        this.left.track_previous = buffer[2] & 4 != 0;
        this.left.pitch_plus = buffer[3] & 4 != 0;
        this.left.pitch_minus = buffer[3] & 8 != 0;
        this.left.headset = buffer[3] & 16 != 0;
        this.left.auto_beat = buffer[2] & 2 != 0;
        this.left.load = buffer[4] & 4 != 0;
        this.left.beat_lock = buffer[3] & 32 != 0;
        this.left.menu.menu = buffer[1] & 64 != 0;
        this.left.menu.one = buffer[2] & 64 != 0;
        this.left.menu.two = buffer[2] & 32 != 0;
        this.left.menu.three = buffer[2] & 16 != 0;
    }
};