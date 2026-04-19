const std = @import("std");
const log = @import("log.zig");
const c = @cImport({
  @cInclude("shadowhook.h");
  @cInclude("And64InlineHook.hpp");
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
  log.info("Initialized Mod: {s}", .{LIB_TAG});

  // Get the library
  const handle = c.shadowhook_dlopen("libPVZ2.so");
  _ = c.dl_iterate_phdr(dl_callback, null);
  if (handle != null) c.shadowhook_dlclose(handle);

  if (pvz2_base != 0) {
    const targetAddr = pvz2_base + 0x0171d9fc;
    log.info("FOUND LIB! Base: 0x{X}", .{pvz2_base});
    log.info("Hooking Target: 0x{X}", .{targetAddr});
    c.A64HookFunction(
      @ptrFromInt(targetAddr),
      @constCast(@ptrCast(&doStateChangeHook)),
      @ptrCast(&originalDoStateChange),
    );
    log.info("And64InlineHook applied to target!", .{});
  } else {
    log.err("Could not locate libPVZ2.so base address.", .{});
  }
}
export const initArrayPtr: *const fn () callconv(.c) void linksection(".init_array") = &mod_main;

var pvz2_base: usize = 0;
fn dl_callback(info: [*c]const c.struct_dl_phdr_info, _: usize, _: ?*anyopaque) callconv(.c) i32 {
  if (info.*.dlpi_name == null) return 0;

  const name = std.mem.span(info.*.dlpi_name);
  if (std.mem.indexOf(u8, name, "libPVZ2.so") != null) {
    const raw_addr: usize = @intCast(info.*.dlpi_addr);
    pvz2_base = raw_addr & 0x0000FFFFFFFFFFFF;
    return 1;
  }
  return 0;
}

export fn JNI_OnLoad(vm: *anyopaque, _: *anyopaque) callconv(.c) i32 {
  _ = vm;
  // _ = __android_log_print(ANDROID_LOG_INFO, LIB_TAG, "JNI OnLoad");

  return 0x00010006;
}