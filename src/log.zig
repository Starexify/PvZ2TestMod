const std = @import("std");
const main = @import("root");
const androidLog = @cImport({
  @cInclude("android/log.h");
});

const TAG = if (@hasDecl(main, "LIB_TAG")) main.LIB_TAG else "DEFAULT_MOD";

pub fn log(prio: c_int, comptime fmt: []const u8, args: anytype) void {
  var buf: [512]u8 = undefined;
  const formatted = std.fmt.bufPrintZ(&buf, fmt, args) catch "Log overflow";
  _ = androidLog.__android_log_print(prio, TAG, "%s", formatted.ptr);
}

pub fn info(comptime fmt: []const u8, args: anytype) void { log(androidLog.ANDROID_LOG_INFO, fmt, args); }
pub fn err(comptime fmt: []const u8, args: anytype) void { log(androidLog.ANDROID_LOG_ERROR, fmt, args); }