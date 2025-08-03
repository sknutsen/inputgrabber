const std = @import("std");

pub const CommandType = enum(u8) {
    readConfig,
    grab,
    ungrab,
    exitProcess,
};

pub const Command = struct {
    Id: CommandType,
};
