pub const Device = struct {
    path: []const u8,
    grabbed: bool = false,

    pub fn isGrabbed(self: *Device) bool {
        return self.grabbed;
    }
};
