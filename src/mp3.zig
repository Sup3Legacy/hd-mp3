
const Levels = struct {
    trebble: u8,
    medium: u8,
    bass: u8,
}

const Selector = struct {
    menu: bool,
    one: bool,
    two: bool,
    three: bool,
}

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
    headphones: bool,
    auto_beat: bool,
    load: bool,
    beat_lock: bool,
    menu: Selector,
}

const MP3 = struct {
    left: Half,
    right: Half,
    crossfader: u8,
    mouse_x: u8,
    mouse_y: u8,
}