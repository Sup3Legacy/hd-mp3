pub const PriorityQueueError = error {
    QueueEmpty,
    QueueFull,
};

pub fn Priority(comptime P: type, comptime T: type) type {
    return struct {
        priority: P,
        value: T,
        id: usize,

        pub fn new(v: T, p: P) @This() {
            const S = struct {
                var x: usize = 0;
            };
            defer S.x += 1;
            return @This() {
                .priority = p,
                .value = v,
                .id = S.x,
            };
        }
    };
}

pub fn PriorityQueue(comptime T: type, comptime P: type, comptime Capacity: usize, fun: fn(*P, *P) bool) type {
    return struct {
        const self = @This();
        const priority_type = Priority(P, T);
        queue: [Capacity]Priority(P, T),
        size: usize,
        // compFunc(a, b) <=> a < b (if min-queue)
        compFunc: fn(*P, *P) bool,

        // Returns a fresh PriorityQueue
        pub fn new() self {
            return self {
                .queue = undefined,
                .size = 0,
                .compFunc = fun,
            };
        }

        // Returns pointer to the top value
        pub fn peek(this: *self) PriorityQueueError!*T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                return &(this.queue[0].value);
            }
        }

        pub fn peek_priority(this: *self) PriorityQueueError!*P {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                return &(this.queue[0].priority);
            }
        }

        // Enqueue a value
        pub fn enqueue(this: *self, data: T, prio: P) PriorityQueueError!void {
            if (this.size == Capacity) {
                return PriorityQueueError.QueueFull;
            }
            this.queue[this.size] = priority_type.new(data, prio);
            this.size += 1;
            this.percolate_up(this.size - 1);
            // Handle priority
            
            return;
        }

        // Dequeues a value
        pub fn pop(this: *self) PriorityQueueError!T {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                var res = this.queue[0].value;
                if (this.size == 1) {
                    this.size = 0;
                    return res;
                }
                this.queue[0] = this.queue[this.size - 1];
                this.size -= 1;
                this.percolate_down(0);
                return res;
            }
        }

        pub update_priority(this: *self, p: P) PriorityQueueError!void {
            if (this.size == 0) {
                return PriorityQueueError.QueueEmpty;
            } else {
                this.queue[0].priority = p;
                this.percolate_down(0);
            }
        }

        fn lexico_order(this: *self, i: usize, j: usize) bool {
            if (this.compFunc(&(this.queue[i].priority), &(this.queue[j].priority))) {
                return true;
            } else if (this.compFunc(&(this.queue[j].priority), &(this.queue[i].priority))) {
                return false;
            } else {
                return (this.queue[i].id < this.queue[j].id);
            }
        }

        fn percolate_up(this: *self, index: usize) void {
            if (index == 0) {
                return;
            }
            var father = (index - 1) / 2;
            if (this.lexico_order(index, father)) {
                var temp = this.queue[father];
                this.queue[father] = this.queue[index];
                this.queue[index] = temp;
                return this.percolate_up(father);
            } else {
                return;
            }
        }

        fn percolate_down(this: *@This(), index: usize) void {
            var left = 2 * index + 1;
            var right = 2 * index + 2;
            var extremum = right;
            if (left >= this.size) {
                return;
            } else if (right >= this.size or this.lexico_order(left, right)) {
                extremum = left;
            }
            if (this.lexico_order(extremum, index)) {
                var temp = this.queue[index];
                this.queue[index] = this.queue[extremum];
                this.queue[extremum] = temp;
                return this.percolate_down(extremum);
            } else {
                return;
            }
        }

        //pub fn update_priority()
    };
}