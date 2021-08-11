pub const ComQueueError = error {
    ComQueueEmpty,
    ComQueueFull,
};

pub fn ComQueue(comptime T: type, comptime Capacity: usize) type {
    return struct {
        const Self = @This();
        values: [Capacity]T,
        in: usize,
        out: usize,
        empty: bool,

        pub fn new() Self {
            return Self {
                .values = undefined,
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
            if (this.is_full()) {
                return ComQueueError.ComQueueFull;
            }
            this.values[this.in] = data;
            this.in = (this.in + 1) % Capacity;
            this.empty = false;
        }

        pub fn pop(this: *Self) ComQueueError!T {
            if (this.is_empty()) {
                return ComQueueError.ComQueueEmpty;
            }
            var res = this.values[this.out];
            this.out = (this.out + 1) % Capacity;
            if (this.out == this.in) {
                this.empty = true;
            }
            return res;
        }
    };
}