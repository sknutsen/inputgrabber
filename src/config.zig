pub const Config = @This();

const std = @import("std");
const Allocator = std.mem.Allocator;
const ArenaAllocator = std.heap.ArenaAllocator;
const posix = std.posix;
const eql = std.mem.eql;
const ParseOptions = std.json.ParseOptions;
const Value = std.json.Value;
const parseFromValue = std.json.parseFromValueLeaky;
const innerParseFromValue = std.json.innerParseFromValue;
const print = std.debug.print;

const configFileName = "inputgrabber.json";

_arena: ?ArenaAllocator = null,
isInitialized: bool = false,
dirPath: []const u8 = "",
opts: Options = undefined,

pub fn init(self: *Config, alloc_gpa: Allocator, setDefaults: bool) !void {
    var dir: []const u8 = undefined;

    self.* = .{
        .isInitialized = true,
        ._arena = ArenaAllocator.init(alloc_gpa),
    };

    const allocator = self._arena.?.allocator();

    var useXDG = false;

    if (posix.getenv("USE_XDG")) |result| {
        useXDG = eql(u8, result, "true");
    }

    if (useXDG) {
        if (posix.getenv("XDG_CONFIG_HOME")) |result| {
            dir = result;
        } else if (posix.getenv("HOME")) |result| {
            dir = try std.fs.path.join(allocator, &.{ result, ".config" });
        }
    } else {
        dir = try std.fs.cwd().realpathAlloc(allocator, ".");
    }

    self.*.dirPath = dir;

    var opts: Options = undefined;

    if (setDefaults) {
        print("Setting default config\n", .{});
        opts = try Options.getDefaultOpts(allocator);
    } else {
        opts = .{
            .deviceName = "",
            .clientName = "",
            .mqtt = "",
        };
    }

    self.*.opts = opts;
}

pub fn deinit(self: *Config) void {
    if (self._arena) |arena| arena.deinit();
    self.* = undefined;
}

pub fn loadConfig(self: *Config) !void {
    errdefer self.deinit();

    const filePath = try self.getFilePath(self._arena.?.allocator());

    print("{s}\n", .{filePath});
    const file = try openFile(filePath, .{ .mode = std.fs.File.OpenMode.read_only });
    defer file.close();

    var contents: [1024]u8 = undefined;
    const bytesRead = try file.readAll(&contents);

    print("contents: {s}\n", .{contents});
    const parsed1 = try std.json.parseFromSlice(Value, self._arena.?.allocator(), contents[0..bytesRead], .{});
    defer parsed1.deinit();

    self.*.opts = try parseFromValue(Options, self._arena.?.allocator(), parsed1.value, .{ .allocate = .alloc_always });
}

pub fn writeConfig(self: *Config) !void {
    errdefer self.deinit();

    const filePath = try self.getFilePath(self._arena.?.allocator());

    const file = try openFile(filePath, .{ .mode = std.fs.File.OpenMode.write_only });
    defer file.close();

    var string = std.ArrayList(u8).init(self._arena.?.allocator());
    try std.json.stringify(self.opts, .{}, string.writer());

    std.debug.print("json: {s}\n", .{string.items});
    try file.writeAll(string.items);
}

fn getFilePath(self: *Config, alloc: Allocator) ![]const u8 {
    const filePath = try std.fs.path.join(alloc, &.{ self.dirPath, configFileName });

    return filePath;
}

fn openFile(path: []const u8, args: std.fs.File.OpenFlags) !std.fs.File {
    const file = std.fs.openFileAbsolute(path, args) catch |err| {
        return switch (err) {
            std.fs.File.OpenError.FileNotFound => try std.fs.createFileAbsolute(path, .{ .read = true }),
            else => err,
        };
    };

    return file;
}

pub const Options = struct {
    deviceName: []const u8,
    mqtt: []const u8,
    clientName: []const u8,
    keyMaps: std.ArrayList(KeyMap) = undefined,

    pub fn getDefaultOpts(alloc: Allocator) !Options {
        var keyMap = std.ArrayList(KeyMap).init(alloc);
        try keyMap.append(KeyMap{ .key = Key.key1, .args = std.ArrayList([]const u8).init(alloc), .type = 0 });

        return .{
            .deviceName = "test",
            .clientName = "inputgrabber",
            .mqtt = "localhost",
            .keyMaps = keyMap,
        };
    }

    pub fn jsonParseFromValue(allocator: Allocator, source: Value, options: ParseOptions) !@This() {
        if (source != .object) return error.UnexpectedToken;

        var keyMaps: std.ArrayList(KeyMap) = undefined;
        if (source.object.get("keyMaps")) |val| {
            const slice = try innerParseFromValue([]const KeyMap, allocator, val, .{});
            keyMaps = std.ArrayList(KeyMap).init(allocator);
            for (slice) |km| {
                try keyMaps.append(km);
            }
        } else {
            keyMaps = std.ArrayList(KeyMap).init(allocator);
        }
        errdefer keyMaps.deinit();

        return Options{
            .deviceName = innerParseFromValue([]const u8, allocator, source.object.get("deviceName").?, options) catch "",
            .mqtt = innerParseFromValue([]const u8, allocator, source.object.get("mqtt").?, options) catch "",
            .clientName = innerParseFromValue([]const u8, allocator, source.object.get("clientName").?, options) catch "",
            .keyMaps = keyMaps,
        };
    }

    pub fn jsonStringify(self: Options, jw: anytype) !void {
        try jw.beginObject();

        // Fields
        try jw.objectField("deviceName");
        try jw.print("\"{s}\"", .{self.deviceName});

        try jw.objectField("clientName");
        try jw.print("\"{s}\"", .{self.clientName});

        try jw.objectField("mqtt");
        try jw.print("\"{s}\"", .{self.mqtt});

        // KeyMaps
        try jw.objectField("keyMaps");
        try jw.beginArray();
        for (self.keyMaps.items) |k| {
            try jw.write(k);
        }
        try jw.endArray();
        try jw.endObject();
    }
};

pub const KeyMap = struct {
    key: Key,
    args: std.ArrayList([]const u8) = undefined,
    type: u8,

    pub fn jsonParseFromValue(allocator: Allocator, source: Value, options: ParseOptions) !@This() {
        if (source != .object) return error.UnexpectedToken;

        var args: std.ArrayList([]const u8) = undefined;
        if (source.object.get("args")) |val| {
            const slice = try innerParseFromValue([][]const u8, allocator, val, .{});
            args = std.ArrayList([]const u8).init(allocator);
            for (slice) |str| {
                try args.append(str);
            }
        } else {
            args = std.ArrayList([]const u8).init(allocator);
        }
        errdefer args.deinit();

        return KeyMap{
            .key = try innerParseFromValue(Key, allocator, source.object.get("key").?, options),
            .type = innerParseFromValue(u8, allocator, source.object.get("type").?, options) catch 0,
            .args = args,
        };
    }

    pub fn jsonStringify(self: KeyMap, jw: anytype) !void {
        try jw.beginObject();

        // Fields
        try jw.objectField("key");
        try jw.write(self.key);

        try jw.objectField("type");
        try jw.write(self.type);

        // KeyMaps
        try jw.objectField("args");
        try jw.beginArray();
        for (self.args.items) |a| {
            try jw.write(a);
        }
        try jw.endArray();
        try jw.endObject();
    }
};

pub const Key = enum(u8) {
    key1,
    key2,
    key3,
    key4,
    key5,
    key6,
    key7,
    key8,
    key9,
    key0,
    keyPlus,
    keyMinus,
};

const FileFlag = enum {
    write_only,
    read_only,
    read_write,

    pub fn getOpenFlag(self: FileFlag) std.fs.File.OpenMode {
        return switch (self) {
            FileFlag.write_only => std.fs.File.OpenMode.write_only,
            FileFlag.read_only => std.fs.File.OpenMode.read_only,
            FileFlag.read_write => std.fs.File.OpenMode.read_write,
        };
    }

    pub fn getCreateFlag(self: FileFlag) std.fs.File.CreateFlags {
        return switch (self) {
            FileFlag.write_only => .{ .write = true },
            FileFlag.read_only => .{ .read = true },
            FileFlag.read_write => .{ .read = true, .write = true },
        };
    }
};
