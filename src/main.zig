const std = @import("std");

const sh = @cImport({
  @cInclude("shadowhook.h");
});

extern fn __android_log_print(prio: i32, tag: [*:0]const u8, fmt: [*:0]const u8, ...) i32;
const ANDROID_LOG_INFO = 4;
const LIB_TAG = "PVZ2_MOD";

export fn mod_main() callconv(.c) void {
  // _ = sh.shadowhook_init(sh.SHADOWHOOK_MODE_SHARED, true);
  _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, sh.shadowhook_get_version());
}

export const init_array_pointer: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");
    return 0x00010006;
}
