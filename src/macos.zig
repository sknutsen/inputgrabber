const std = @import("std");
const IOCTL = @import("ioctl.zig").IOCTL;

pub const IoctlMacos = struct {
    pub fn init(ioctl: *IOCTL) void {
        ioctl.* = .{
            .macos = .{},
        };
        return;
    }

    pub fn grab(_: *IoctlMacos) !void {}

    pub fn ungrab(_: *IoctlMacos) void {}

    pub fn processInput(_: *IoctlMacos) !void {}
};
