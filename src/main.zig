const std = @import("std");
const log = @import("log.zig");
const sh = @cImport({
  @cInclude("shadowhook.h");
});
const HookUtil = @import("hookUtil.zig");
const GameStateMgr = @import("popcap/GameStateMgr.zig").GameStateMgr;
const Zombie = @import("popcap/Zombie.zig").Zombie;

pub const LIB_TAG = "PVZ2_MOD";

export fn mod_main() callconv(.c) void {}
export const initArrayPtr: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

pub var originalDoStateChange: ?*anyopaque = null;
fn doStateChangeHook(self: *GameStateMgr, param2: u32, p3: u64, p4: u64, p5: u64, p6: u64, p7: u64, p8: u64) callconv(.c) void {
  log.info("State Change Detected! New State: {d} {d} {d} {d} {d} {d} {d}", .{param2, p3, p4, p5, p6, p7, p8});
  self.DoStateChange(originalDoStateChange, param2, p3, p4, p5, p6, p7, p8);
}

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");

  // Initialize ShadowHook
  initShadowHook() catch |err| {
    log.err("Critical Failure: {any}", .{err});
    return 0x00010006;
  };

  log.info("Initialized Mod: {s}", .{LIB_TAG});
  log.info("Initialized ShadowHook: {s}", .{sh.shadowhook_get_version()});

  // Get the library address and hook into a function
  _ = sh.dl_iterate_phdr(@ptrCast(&HookUtil.dl_callback), null);
  if (HookUtil.pvz2_base != 0) {
    log.info("FOUND LIB! Base: 0x{X}", .{HookUtil.pvz2_base});
    HookUtil.hookFunction(GameStateMgr.offsets.DoStateChange,&doStateChangeHook,&originalDoStateChange);
  }
  else {
    log.err("Could not locate libPVZ2.so base address.", .{});
  }

  return 0x00010006;
}

fn initShadowHook() !void {
  const rc = sh.shadowhook_init(sh.SHADOWHOOK_MODE_UNIQUE, true);
  if (rc != 0 and rc != 100) return error.ShadowHookInitFailed;
}