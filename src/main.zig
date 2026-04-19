const std = @import("std");
const log = @import("log.zig");
const c = @cImport({
  @cInclude("stdint.h");
  @cInclude("And64InlineHook.hpp");
  @cInclude("dlfcn.h");
});

pub const LIB_TAG = "PVZ2_MOD";

const DoStateChange = *const fn (p1: usize, p2: u32,p3: u64, p4: u64, p5: u64, p6: u64, p7: u64, p8: u64) callconv(.c) void;
var originalDoStateChange: ?*anyopaque = null;

fn doStateChangeHook(param1: usize,param2: u32,p3: u64, p4: u64, p5: u64, p6: u64, p7: u64, p8: u64) callconv(.c) void {
  log.info("State Change Detected! New State: {d}", .{param2});

  if (originalDoStateChange) |origPtr| {
    const orig: DoStateChange = @ptrCast(@alignCast(origPtr));
    orig(param1, param2, p3, p4, p5, p6, p7, p8);
  }
}

export fn mod_main() callconv(.c) void {}
export const initArrayPtr: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");

  log.info("Initialized Mod: {s}", .{LIB_TAG});

  const baseAddr = getModuleBase("libPVZ2.so") catch |err| {
    log.err("Failed to get module base: {any}", .{err});
    return 0x00010006;
  };
  const targetAddr = (baseAddr + 0x0171d9fc);

  log.info("--- DEBUG TRACE ---", .{});
  log.info("Base Address: 0x{X}", .{baseAddr});
  log.info("Target Address: 0x{X}", .{targetAddr});

  // c.A64HookFunction(
  //   @ptrFromInt(targetAddr),
  //   @constCast(@ptrCast(&doStateChangeHook)),
  //   @ptrCast(&originalDoStateChange),
  // );

  return 0x00010006;
}

fn getModuleBase(libName: []const u8) !usize {
  const file = try std.fs.openFileAbsolute("/proc/self/maps", .{});
  defer file.close();

  var buf: [4096]u8 = undefined;
  var file_reader = file.reader(&buf);
  const reader = &file_reader.interface;

  while (reader.takeDelimiterExclusive('\n')) |line| {
    if (std.mem.indexOf(u8, line, libName)) |_| {
      const hyphen_idx = std.mem.indexOf(u8, line, "-") orelse continue;
      return try std.fmt.parseInt(usize, line[0..hyphen_idx], 16);
    }
  }
  else |err| switch (err) {
    error.EndOfStream => return error.ModuleNotFound,
    else => return err,
  }
  return error.ModuleNotFound;
}
