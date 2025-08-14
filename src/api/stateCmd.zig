const std = @import("std");
const zap = @import("zap");

const state = &@import("../state.zig").state;

pub const StateCmd = @This();

alloc: std.mem.Allocator = undefined,

path: []const u8,
error_strategy: zap.Endpoint.ErrorStrategy = .log_to_response,

pub fn init(
    a: std.mem.Allocator,
    state_path: []const u8,
) !StateCmd {
    var cmd = StateCmd{
        .alloc = a,
        .path = state_path,
    };
    errdefer cmd.deinit();

    try cmd.setupRoutes();

    return cmd;
}

pub fn deinit(_: *StateCmd) void {
    getRoutes.deinit();
    postRoutes.deinit();
}

pub fn get(_: *StateCmd, r: zap.Request) !void {
    if (r.path) |path| {
        if (getRoutes.get(path)) |rt| {
            try rt(r);
            return;
        }
    }
}

pub fn post(_: *StateCmd, r: zap.Request) !void {
    if (r.path) |path| {
        if (postRoutes.get(path)) |rt| {
            try rt(r);
            return;
        }
    }
}

pub fn options(_: *StateCmd, r: zap.Request) !void {
    try r.setHeader("Access-Control-Allow-Origin", "*");
    try r.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS, HEAD");
    r.setStatus(zap.http.StatusCode.no_content);
    r.markAsFinished(true);
}

pub fn head(_: *StateCmd, r: zap.Request) !void {
    r.setStatus(zap.http.StatusCode.no_content);
    r.markAsFinished(true);
}

var getRoutes: std.StringHashMap(zap.HttpRequestFn) = undefined;
var postRoutes: std.StringHashMap(zap.HttpRequestFn) = undefined;

fn setupRoutes(self: *StateCmd) !void {
    getRoutes = std.StringHashMap(zap.HttpRequestFn).init(self.alloc);
    postRoutes = std.StringHashMap(zap.HttpRequestFn).init(self.alloc);
    try postRoutes.put("/state/stop", stop);
}

fn stop(r: zap.Request) !void {
    state.running = false;
    r.setStatus(zap.http.StatusCode.ok);
    r.markAsFinished(true);
    zap.stop();
}
