const std = @import("std");
const zap = @import("zap");

const state = &@import("state.zig").state;

const configCmd = @import("api/configCmd.zig");
const stateCmd = @import("api/stateCmd.zig");

pub fn runZap() !void {
    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
        .max_clients = 100000,
    });
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
            return;
        }
    }
    try r.sendBody("<html><body><h1>hello from zap!!!</h1></body></html>");
}
