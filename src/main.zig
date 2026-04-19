const std = @import("std");
const log = @import("log.zig");
const sh = @cImport({
  @cInclude("shadowhook.h");
});

pub const LIB_TAG = "PVZ2_MOD";

export fn mod_main() callconv(.c) void {
  // _ = sh.shadowhook_init(sh.SHADOWHOOK_MODE_SHARED, true);

  log.info("Initialized Mod: {s}", .{LIB_TAG});
  log.info("ShadowHook Version: {s}", .{sh.shadowhook_get_version()});
}

export const init_array_pointer: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");
  return 0x00010006;
}
