const std = @import("std");
const log = @import("log.zig");
const sh = @cImport({

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

  const funcAddrOffset = 0x0171d9fc;


  log.info("--- DEBUG TRACE ---", .{});

  return 0x00010006;
}
