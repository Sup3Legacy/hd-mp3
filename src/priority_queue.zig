pub const PriorityQueueError = error {
    QueueEmpty,
    QueueFull,
};

pub fn PriorityQueue(comptime T: type, comptime Capacity: usize) type {
    return struct {
        values: [Capacity]T,
        size: usize,
        // compFunc(a, b) <=> a < b (if min-queue)
        compFunc: fn(*T, *T) bool,

        pub fn peak_top(this: *@This()) PriorityQueueError!*T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                return &(this.values[0]);
            }
        }

        pub fn enqueue(this: *@This(), data: T) PriorityQueueError!void {
            if (this.size == Capacity) {
                return PriorityQueueError.QueueFull;
            }
        }

        pub fn dequeue(this: *This()) PriorityQueueError!T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            }
        }
    };
}