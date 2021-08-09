const LedInfo = struct {
    byte: u8,
    value: u8,
};

const HalfLedArray = struct {
    play: LedInfo,
    cue_button: LedInfo,
    headset: LedInfo,
    auto_beat: LedInfo,
    beat_lock: LedInfo,
    fx: LedInfo,
    cue: LedInfo,
    loop: LedInfo,
};

const LedArray = struct {
    left: HalfLedArray,
    right: HalfLedArray,
};

const LEDMapping = LedArray {
    .left = HalfLedArray {
        .play = LedInfo {
            .byte = 2,
            .value = 1,
        },
        .cue_button = LedInfo {
            .byte = 2,
            .value = 8,
        },
        .headset = LedInfo {
            .byte = 2,
            .value = 2,
        },
        .auto_beat = LedInfo {
            .byte = 2,
            .value = 16,
        },
        .beat_lock = LedInfo {
            .byte = 1,
            .value = 1,
        },
        .fx = LedInfo {
            .byte = 1,
            .value = 4,
        },
        .cue = LedInfo {
            .byte = 1,
            .value = 128,
        },
        .loop = LedInfo {
            .byte = 2,
            .value = 64,
        },
    },
    .right = HalfLedArray {
        .play = LedInfo {
            .byte = 1,
            .value = 64,
        },
        .cue_button = LedInfo {
            .byte = 1,
            .value = 32,
        },
        .headset = LedInfo {
            .byte = 2,
            .value = 4,
        },
        .auto_beat = LedInfo {
            .byte = 2,
            .value = 32,
        },
        .beat_lock = LedInfo {
            .byte = 1,
            .value = 2,
        },
        .fx = LedInfo {
            .byte = 1,
            .value = 8,
        },
        .cue = LedInfo {
            .byte = 1,
            .value = 16,
        },
        .loop = LedInfo {
            .byte = 2,
            .value = 128,
        },
    },
};


const HalfLedState = struct {
    play: bool,
    cue_button: bool,
    headset: bool,
    auto_beat: bool,
    beat_lock: bool,
    fx: bool,
    cue: bool,
    loop: bool,
};

const LedState = struct {
    left: HalfLedState,
    right: HalfLedState,

    pub fn new() @This() {
        return LedState {
            .left = HalfLedState {
                .play = false,
                .cue_button = false,
                .headset = false,
                .auto_beat = false,
                .beat_lock = false,
                .fx = false,
                .cue = false,
                .loop = false,
            },
            .right = HalfLedState {
                .play = false,
                .cue_button = false,
                .headset = false,
                .auto_beat = false,
                .beat_lock = false,
                .fx = false,
                .cue = false,
                .loop = false,
            },
        };
    }
};