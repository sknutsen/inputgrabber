const linux = @import("ioctl/linux.zig").IoctlLinux;
const macos = @import("ioctl/macos.zig").IoctlMacos;
const windows = @import("ioctl/windows.zig").IoctlWindows;
const Device = @import("ioctl/device.zig").Device;
const Config = @import("config.zig").Config;
pub const CommandType = @import("commands.zig").CommandType;

pub const CommandPayload = struct {
    type: CommandType,
    customCommand: ?[]u8,
};

pub const IOCTL = union(enum) {
    linux: linux,
    macos: macos,
    windows: windows,

    pub fn init(self: *IOCTL, config: *Config) void {
        return linux.init(self, config);
    }

    pub fn toggleGrab(self: *IOCTL) !void {
        if (self.device.isGrabbed()) {
            try self.Grab();
        } else {
            self.Ungrab();
        }
    }

    pub fn grab(self: *IOCTL) !void {
        return switch (self.*) {
            inline else => |*i| return try i.grab(),
        };
    }

    pub fn ungrab(self: *IOCTL) void {
        return switch (self.*) {
            inline else => |*i| return i.ungrab(),
        };
    }

    pub fn processInput(self: *IOCTL) !void {
        return switch (self.*) {
            inline else => |*i| return try i.processInput(),
        };
    }

    pub fn getCommand(self: *IOCTL, code: u16) CommandPayload {
        return switch (self.*) {
            inline else => |*i| return i.getCommand(code),
        };
    }

    pub fn send(self: *IOCTL) !void {
        return switch (self.*) {
            inline else => |*i| return i.send(),
        };
    }
};
