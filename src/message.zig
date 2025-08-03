const std = @import("std");
const mailbox = @import("deps/mailbox/src/mailbox.zig");

pub const MsgBlock = struct {};

const Msgs = mailbox.MailBox(MsgBlock);

pub var msgs: Msgs = undefined;
