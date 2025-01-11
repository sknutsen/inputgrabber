const std = @import("std");
const IOCTL = @import("ioctl.zig").IOCTL;

pub const IoctlWindows = struct {
    pub fn init(ioctl: *IOCTL) void {
        ioctl.* = .{
            .windows = .{},
        };
        return;
    }

    pub fn grab(_: *IoctlWindows) !void {}

    pub fn ungrab(_: *IoctlWindows) void {}

    pub fn processInput(_: *IoctlWindows) !void {}
};
