const std = @import("std");
const log = @import("log.zig");
const sh = @cImport({
  @cInclude("shadowhook.h");
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

export fn mod_main() callconv(.c) void {

}
export const initArrayPtr: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");

  const rc = sh.shadowhook_init(sh.SHADOWHOOK_MODE_SHARED, true);
  log.info("ShadowHook Init returned: {d}", .{rc});

  log.info("Initialized Mod: {s}", .{LIB_TAG});
  log.info("ShadowHook Version: {s}", .{sh.shadowhook_get_version()});

  const handle = sh.shadowhook_dlopen("libPVZ2.so");
  if (handle == null) {
    log.err("Could not find the library libPVZ2.so", .{});
  }
  defer sh.shadowhook_dlclose(handle);

  const funcAddrOffset = 0x0171d9fc;
  const baseAddr = @intFromPtr(handle);
  const targetAddr = baseAddr + funcAddrOffset;

  log.info("--- DEBUG TRACE ---", .{});
  log.info("Handle: {?p}", .{handle});
  log.info("Base Address: 0x{X}", .{baseAddr});
  log.info("Final Hook Target: 0x{X}", .{targetAddr});

  // void *shadowhook_hook_func_addr(void *func_addr, void *new_addr, void **orig_addr);
  const stub = sh.shadowhook_hook_func_addr(
    @ptrFromInt(targetAddr),
    @constCast(@ptrCast(&doStateChangeHook)),
    &originalDoStateChange,
  );

  if (stub == null) {
    const err = sh.shadowhook_get_errno();
    log.err("Hook FAILED! Error {d}: {s}", .{err, sh.shadowhook_to_errmsg(err)});
  }

  return 0x00010006;
}
