# hd-mp3

Custom userspace HID driver for the Hercules DJ Control MP3.

# Data input

A small and naive daemon receives the packets from the USB interface and decodes it. It is provided the possibility of assigning custom functions to be executed on value change, and this on a per button/slider basis.

For now, these functions do not get launched in a separate thread, but this is the long-term goal.

# Data output

A simple LED-controlling daemon drives the LEDs. It runs in a different thread and can receive requests via a mailbox. It is capable of handling asynchronously blinking LEDs efficiently through a time-based priority queue.