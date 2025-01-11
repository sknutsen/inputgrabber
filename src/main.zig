const std = @import("std");
const IOCTL = @import("ioctl.zig").IOCTL;

pub fn main() !void {
    var ioctl: IOCTL = undefined;
    ioctl.init();

    try ioctl.grab();

    defer {
        std.debug.print("Cleaning up...", .{});
        ioctl.ungrab();
    }

    while (true) {
        try ioctl.processInput();
    }
}
