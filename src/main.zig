const std = @import("std");
const IOCTL = @import("ioctl.zig").IOCTL;
const Config = @import("config.zig").Config;
const Command = @import("commands.zig").Command;
const CommandType = @import("commands.zig").CommandType;
const mailbox = @import("deps/mailbox/src/mailbox.zig");
const messages = @import("message.zig");

pub fn main() !void {
    var config: Config = undefined;

    var alloc_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = alloc_gpa.deinit();

    try config.init(alloc_gpa.allocator(), false);
    errdefer config.deinit();

    try config.loadConfig();
    // try config.writeConfig();

    var ioctl: IOCTL = undefined;
    ioctl.init(&config);

    var thread: std.Thread = std.Thread.spawn(.{}, ioctlThread, .{ioctl});
    defer thread.join();
}

fn ioctlThread(ioctl: *IOCTL) void {
    try ioctl.grab();

    defer {
        std.debug.print("Cleaning up...", .{});
        ioctl.ungrab();
    }

    while (true) {
        const envolope = ioctl.msgs.receive(10000000);
        switch (envolope) {
            .Closed => break,
            else => {},
        }
        if (envolope) |_| {
            break;
        }
        try ioctl.processInput();
    }
}
