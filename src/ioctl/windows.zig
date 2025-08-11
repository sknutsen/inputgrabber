const std = @import("std");
const IOCTL = @import("../ioctl.zig").IOCTL;
const Config = @import("../config.zig").Config;

pub const IoctlWindows = struct {
    config: *Config = undefined,

    pub fn init(ioctl: *IOCTL, config: *Config) void {
        ioctl.* = .{
            .windows = .{
                .config = config,
            },
        };
        return;
    }

    pub fn grab(_: *IoctlWindows) !void {}

    pub fn ungrab(_: *IoctlWindows) void {}

    pub fn processInput(_: *IoctlWindows) !void {}
};
