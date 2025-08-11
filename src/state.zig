const std = @import("std");

pub var state: State = undefined;

pub const State = struct {
    running: bool = false,
    configChanged: bool = false,

    pub fn init(self: *State) !void {
        self.* = .{
            .running = true,
        };
        errdefer self.deinit();
    }

    pub fn deinit(self: *State) void {
        self.running = false;
    }

    pub fn isRunning(self: *State) bool {
        return self.running;
    }

    pub fn configHasChanged(self: *State) bool {
        return self.configChanged;
    }
};
