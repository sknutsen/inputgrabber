const std = @import("std");
const IOCTL = @import("../ioctl.zig").IOCTL;
const Config = @import("../config.zig").Config;

pub const IoctlMacos = struct {
    config: *Config = undefined,

    pub fn init(ioctl: *IOCTL, config: *Config) void {
        ioctl.* = .{
            .macos = .{
                .config = config,
            },
        };
        return;
    }

    pub fn grab(_: *IoctlMacos) !void {}

    pub fn ungrab(_: *IoctlMacos) void {}

    pub fn processInput(_: *IoctlMacos) !void {}
};
