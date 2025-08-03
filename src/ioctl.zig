const linux = @import("linux.zig").IoctlLinux;
const macos = @import("macos.zig").IoctlMacos;
const windows = @import("windows.zig").IoctlWindows;
const Device = @import("device.zig").Device;
const Config = @import("config.zig").Config;
const MsgBlock = @import("message.zig").MsgBlock;
const Msgs = @import("message.zig").Msgs;

pub const CommandType = enum(u8) {
    Kill,
    PrintInfo,
    Custom,
};

pub const CustomCommand = *const fn () void;

pub const CommandPayload = extern struct {
    type: CommandType,
    customCommand: ?CustomCommand,
};

pub const IOCTL = union(enum) {
    pub var msgs: Msgs = undefined;

    linux: linux,
    macos: macos,
    windows: windows,

    pub fn init(self: *IOCTL, config: *Config) void {
        self.msgs = .{};
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

    pub fn send(self: *IOCTL, msg: MsgBlock) !void {
        return switch (self.*) {
            inline else => |*i| return i.send(msg),
        };
    }
};
