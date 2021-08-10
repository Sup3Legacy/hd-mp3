pub const PriorityQueueError = error {
    QueueEmpty,
    QueueFull,
};

pub fn Priority(comptime T: type, comptime P: type) type {
    return struct {
        priority: P,
        value: T,
        compFunc: fn(*P, *P) bool,

        pub fn new(v: P, p: P, f: fn(*P, *P) bool) @This() {
            return @This() {
                .priority = p,
                .value = v,
                .compFunc = f,
            }
        }
    }
}

pub fn PriorityQueue(comptime T: type, comptime P: type, comptime Capacity: usize) type {
    return struct {
        priority_type: type,
        values: [Capacity]T,
        size: usize,
        // compFunc(a, b) <=> a < b (if min-queue)
        compFunc: fn(*T, *T) bool,

        // Returns a fresh PriorityQueue
        pub fn new(fun: fn(*T, *T) bool) @This() {
            return @This() {
                .priority_type = Priority(T, P),
                .values = [Capacity]T,
                .size = 0,
                .compFunc = fun,
            };
        }

        // Returns pointer to the top value
        pub fn peak_top(this: *@This()) PriorityQueueError!*T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                return &(this.values[0]);
            }
        }

        // Enqueue a value
        pub fn enqueue(this: *@This(), data: T) PriorityQueueError!void {
            if (this.size == Capacity) {
                return PriorityQueueError.QueueFull;
            }
        }

        // Dequeues a value
        pub fn dequeue(this: *@This()) PriorityQueueError!T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            }
        }

        pub fn update_priority()
    };
}