const std = @import("std");
const zap = @import("zap");

const state = &@import("../state.zig").state;
const Config = @import("../config.zig");
const config = &@import("../config.zig").config;

pub const ConfigCmd = @This();

alloc: std.mem.Allocator = undefined,

path: []const u8,
error_strategy: zap.Endpoint.ErrorStrategy = .log_to_response,

pub fn init(
    a: std.mem.Allocator,
    config_path: []const u8,
) !ConfigCmd {
    var self: ConfigCmd = ConfigCmd{
        .alloc = a,
        .path = config_path,
    };
    errdefer self.deinit();

    try self.setupRoutes();

    return self;
}

pub fn deinit(_: *ConfigCmd) void {
    getRoutes.deinit();
    postRoutes.deinit();
}

pub fn get(self: *ConfigCmd, r: zap.Request) !void {
    std.debug.print("config get\n", .{});
    if (r.path) |path| {
        if (getRoutes.get(path)) |rt| {
            try rt(self, r);
            return;
        }
    }
}

pub fn post(self: *ConfigCmd, r: zap.Request) !void {
    std.debug.print("config post\n", .{});
    if (r.path) |path| {
        if (postRoutes.get(path)) |rt| {
            try rt(self, r);
            return;
        }
    }
}

pub fn options(_: *ConfigCmd, r: zap.Request) !void {
    try r.setHeader("Access-Control-Allow-Origin", "*");
    try r.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD");
    r.setStatus(zap.http.StatusCode.no_content);
    r.markAsFinished(true);
}

const CfgRequestFn = *const fn (*ConfigCmd, zap.Request) anyerror!void;

pub fn head(_: *ConfigCmd, r: zap.Request) !void {
    r.setStatus(zap.http.StatusCode.no_content);
    r.markAsFinished(true);
}

var getRoutes: std.StringHashMap(CfgRequestFn) = undefined;
var postRoutes: std.StringHashMap(CfgRequestFn) = undefined;

fn setupRoutes(self: *ConfigCmd) !void {
    getRoutes = std.StringHashMap(CfgRequestFn).init(self.alloc);
    postRoutes = std.StringHashMap(CfgRequestFn).init(self.alloc);

    try getRoutes.put("/config/get", getConfig);
    try postRoutes.put("/config/reload", reload);
    try postRoutes.put("/config/update", updateConfig);
}

fn getConfig(self: *ConfigCmd, r: zap.Request) !void {
    const json = try std.json.stringifyAlloc(self.alloc, config.opts, .{});
    try r.sendJson(json);
}

fn reload(_: *ConfigCmd, r: zap.Request) !void {
    state.configChanged = true;
    r.setStatus(zap.http.StatusCode.ok);
    r.markAsFinished(true);
}

fn updateConfig(self: *ConfigCmd, r: zap.Request) !void {
    if (r.body) |body| {
        var cfg: Config = undefined;
        try cfg.init(self.alloc, false);
        defer cfg.deinit();

        const maybe_load_error = cfg.loadConfigFromJson(body);
        if (maybe_load_error) {
            const maybe_write_error = cfg.writeConfig();
            if (maybe_write_error) {
                state.configChanged = true;
                r.setStatus(zap.http.StatusCode.ok);
                r.markAsFinished(true);
                return;
            } else |err| {
                std.debug.print("Update cfg error: {}\n", .{err});
            }
        } else |err| {
            std.debug.print("Update cfg error: {}\n", .{err});
        }
    }

    r.setStatus(zap.http.StatusCode.bad_request);
    r.markAsFinished(true);
}
