const std = @import("std");
const IOCTL = @import("ioctl.zig").IOCTL;
const config = &@import("config.zig").config;
const Command = @import("commands.zig").Command;
const CommandType = @import("commands.zig").CommandType;
const state = &@import("state.zig").state;
const zap = @import("zap");

const runZap = @import("api.zig").runZap;

pub fn main() !void {
    try state.init();
    defer state.deinit();

    var alloc_gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = alloc_gpa.deinit();

    try config.init(alloc_gpa.allocator(), false);
    defer config.deinit();

    // try config.writeConfig();
    try config.loadConfig();

    var thread = try std.Thread.spawn(.{}, ioctlThread, .{});
    defer thread.join();

    try runZap(alloc_gpa.allocator());
}

fn ioctlThread() !void {
    var ioctl: IOCTL = undefined;
    ioctl.init(config);

    try ioctl.grab();

    defer {
        std.debug.print("Cleaning up...\n", .{});
        ioctl.ungrab();
        state.running = false;
    }

    while (state.isRunning()) {
        if (state.configHasChanged()) {
            try config.loadConfig();
            state.configChanged = false;
        }

        try ioctl.processInput();
    }
}
