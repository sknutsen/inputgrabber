const std = @import("std");
const zap = @import("zap");

const state = &@import("state.zig").state;

const ConfigCmd = @import("api/configCmd.zig");
const StateCmd = @import("api/stateCmd.zig");

pub fn runZap(allocator: std.mem.Allocator) !void {
    var listener = zap.Endpoint.Listener.init(allocator, .{
        .port = 3000,
        .on_request = on_request,
        .on_error = on_error,
        .log = true,
        .max_clients = 100000,
        .max_body_size = 100 * 1024 * 1024,
    });
    defer listener.deinit();

    var cfg = try ConfigCmd.init(allocator, "/config");
    defer cfg.deinit();

    var stateCmd = try StateCmd.init(allocator, "/state");
    defer stateCmd.deinit();

    try listener.register(&cfg);
    try listener.register(&stateCmd);

    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    zap.start(.{
        .threads = 2,
        .workers = 1, // 1 worker enables sharing state between threads
    });
}

fn on_request(r: zap.Request) !void {
    if (r.path) |the_path| {
        std.debug.print("path: {s}\n", .{the_path});

        if (std.mem.eql(u8, the_path, "/reload")) {
            state.configChanged = true;
            try r.sendBody("<html><body><h1>reloading...</h1></body></html>");
            return;
        }

        if (std.mem.eql(u8, the_path, "/stop")) {
            state.running = false;
            try r.sendBody("<html><body><h1>stopping...</h1></body></html>");
            zap.stop();
            return;
        }
    }
}

// this is just to demo that we could catch arbitrary errors as fallback
fn on_error(_: zap.Request, err: anyerror) void {
    std.debug.print("\n\n\nOh no!!! We didn't chatch this error: {}\n\n\n", .{err});
}
