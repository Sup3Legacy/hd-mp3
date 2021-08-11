pub const ComQueueError = error {
    ComQueueEmpty,
    ComQueueFull,
};

pub fn ComQueue(comptime T: type, comptime Capacity: usize) type {
    return struct {
        const Self @This();
        values: [Capacity]T,
        size: usize,
        in: usize,
        out: usize,
        empty: bool,

        pub fn new() Self {
            return Self {
                .values = undefined,
                .size = 0,
                .in = 0,
                .out = 0,
                .empty = true,
            };
        }

        pub fn is_empty(this: *Self) bool {
            return this.empty;
        }

        pub fn is_full(this: *Self) bool {
            return (this.in == this.out) and !this.is_empty();
        }

        pub fn push(this: *Self, data: T) ComQueueError!void {
            if (this.size = Capacity) {
                return ComQueueError.ComQueueFull;
            }
            this.values[this.in] = data;
            this.in = (this.in + 1) % Capacity;
            this.size += 1;
        }

        pub fn pop(this: *Self) ComQueueError!T {
            if (this.size == 0) {
                return ComQueueError.ComQueueEmpty;
            }
            defer this.size -= 1;
            defer this.out = (this.out + 1) % Capacity;
            return this.values[this.out];
        }
    };
}