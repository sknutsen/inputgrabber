const std = @import("std");
const linux = std.os.linux;
const consts = @import("linux_constants.zig");
const Device = @import("device.zig").Device;
const IOCTL = @import("../ioctl.zig").IOCTL;
const CommandPayload = @import("../ioctl.zig").CommandPayload;
const CommandType = @import("../ioctl.zig").CommandType;
const Config = @import("../config.zig").Config;

const c = @cImport({
    @cInclude("linux/input.h");
});

const timeval = extern struct {
    tv_sec: i64, // Seconds
    tv_usec: i64, // Microseconds
};

const input_event = extern struct {
    time: timeval, // Event timestamp
    type: u16, // Event type (e.g., EV_KEY, EV_REL, EV_ABS)
    code: u16, // Event code (e.g., KEY_A, REL_X)
    value: i32, // Event value (e.g., 1 for key press, 0 for release)
};

const deviceName = "usb-MOSART_Semi._2.4G_Keyboard_Mouse-event-kbd";

pub const IoctlLinux = struct {
    const Self = @This();

    config: *Config = undefined,
    device: Device,
    fd: std.fs.File = undefined,

    pub fn init(ioctl: *IOCTL, config: *Config) void {
        ioctl.* = .{
            .linux = .{
                .config = config,
                .device = .{
                    .path = &deviceName.*,
                },
            },
        };

        return;
    }

    pub fn grab(self: *Self) !void {
        var gpa = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();
        defer _ = gpa.deinit();

        const devicePath = try std.fs.path.join(allocator, &.{ consts.kbdDevicePath, self.config.opts.deviceName });
        defer allocator.free(devicePath);

        std.debug.print("opening device fp at path: {s}\n", .{devicePath});
        self.fd = try std.fs.openFileAbsolute(devicePath, .{ .mode = .read_only, .lock = .exclusive });
        switch (linux.E.init(linux.ioctl(self.fd.handle, c.EVIOCGRAB, @intFromEnum(consts.IOCmds.grab)))) {
            linux.E.SUCCESS => {
                std.debug.print("path: {s}\n", .{devicePath});
            },
            else => |e| {
                std.debug.print("{d}\n", .{e});
                return;
            },
        }
    }

    pub fn ungrab(self: *Self) void {
        _ = linux.ioctl(self.fd.handle, c.EVIOCGRAB, @intFromEnum(consts.IOCmds.ungrab));
        self.fd.close();
    }

    pub fn processInput(self: *Self) !void {
        var eventBuffer: [@sizeOf(input_event)]u8 = undefined;
        // Read a single input_event from the device
        const bytesRead = try self.fd.reader().read(&eventBuffer);
        if (bytesRead != @sizeOf(input_event)) {
            std.debug.print("Incomplete read: {d} bytes (expected {d})\n", .{ bytesRead, @sizeOf(input_event) });
            return;
        }

        // Parse the input_event
        var event: input_event = undefined;
        event = @as(*input_event, @alignCast(@ptrCast(&eventBuffer))).*;
        // Print event information
        // std.debug.print("Event: time={d}.{d}, type={d}, code={d}, value={d}\n", .{ event.time.tv_sec, event.time.tv_usec, event.type, event.code, event.value });
        const eventId: consts.Events = @enumFromInt(event.type);
        switch (eventId) {
            consts.Events.EVENT_SYN => {},
            consts.Events.EVENT_KEY => {
                const keyEventVal: consts.KeyEventValues = @enumFromInt(event.value);
                switch (keyEventVal) {
                    consts.KeyEventValues.press => {
                        const command = self.getCommand(event.code);
                        switch (command.type) {
                            CommandType.exitProcess => return,
                            CommandType.print => std.debug.print("Key pressed: code={d}\n", .{event.code}),
                            // CommandType.Custom => command.customCommand.?(),
                            else => {
                                std.debug.print("Key event: {d}\n", .{event.value});
                            },
                        }
                    },
                    else => {},
                }
                // if (keyEventVal == consts.KeyEventValues.press) {
                //     const command = self.getCommand(event.code);
                //     switch (command.type) {
                //         CommandType.exitProcess => return,
                //         CommandType.print => std.debug.print("Key pressed: code={d}\n", .{event.code}),
                //         // CommandType.Custom => command.customCommand.?(),
                //         else => {},
                //     }
                // } else if (event.value == consts.KeyEventValues.release) {
                //     // std.debug.print("Key released: code={d}\n", .{event.code});
                // } else {
                //     // std.debug.print("Event: time={d}.{d}, type={d}, code={d}, value={d}\n", .{ event.time.tv_sec, event.time.tv_usec, event.type, event.code, event.value });
                // }
            },
            consts.Events.EVENT_REL => {
                std.debug.print("Relative event: code={d}, value={d}\n", .{ event.code, event.value });
            },
            consts.Events.EVENT_ABS => {
                std.debug.print("Absolute event: code={d}, value={d}\n", .{ event.code, event.value });
            },
            consts.Events.EVENT_MSC => {},
            consts.Events.EVENT_LED => {},
            else => {
                std.debug.print("Unknown event type: {d}\n", .{event.type});
            },
        }
    }

    pub fn getCommand(_: *Self, code: u16) CommandPayload {
        return switch (code) {
            // consts.KEY_1 => .{ .type = CommandType.PrintInfo, .customCommand = null },
            // consts.KEY_KPDOT => .{ .type = CommandType.Kill, .customCommand = null },
            else => .{ .type = CommandType.print, .customCommand = null },
        };
    }

    pub fn send(_: *Self) !void {}
};
