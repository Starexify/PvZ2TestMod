const std = @import("std");
const log = @import("log.zig");
const sh = @cImport({
  @cInclude("shadowhook.h");
});
const androidStd = @cImport({
  @cInclude("stdlib.h");
});

pub var pvz2_base: usize = 0;

pub fn dl_callback(info: [*c]sh.struct_dl_phdr_info, _: usize, _: ?*anyopaque) callconv(.c) i32 {
  if (info.*.dlpi_name == null) return 0;

  const name = std.mem.span(info.*.dlpi_name);
  if (std.mem.indexOf(u8, name, "libPVZ2.so") != null) {
    const raw_addr: usize = @intCast(info.*.dlpi_addr);
    pvz2_base = raw_addr & 0x0000FFFFFFFFFFFF;
    return 1;
  }
  return 0;
}

/// Helper function for hooking into functions
pub fn hookFunction(offset: usize, newFuncOffset: *const anyopaque, ogFuncPtr: *?*anyopaque) void {
  if (pvz2_base == 0) {
    log.err("Cannot hook offset 0x{X}: Base address not found!", .{offset});
    return;
  }

  const targetAddr = pvz2_base + offset;
  log.info("Hooking Target: 0x{X}", .{targetAddr});
  const stub = sh.shadowhook_hook_func_addr(@ptrFromInt(targetAddr), @constCast(newFuncOffset), @ptrCast(ogFuncPtr));
  if (stub == null) {
    const msg = sh.shadowhook_to_errmsg(sh.shadowhook_get_errno());
    log.err("Hook into 0x{X} Failed: {s}", .{offset, std.mem.span(msg)});
  }
  else {
    log.info("Hooked into 0x{X}.", .{offset});
  }
}

/// Helper function to get variables
pub fn getDat(offset: usize) u64 {
  if (pvz2_base == 0) {
    log.err("Cannot hook offset 0x{X}: Base address not found!", .{offset});
    return 0;
  }

  const targetAddr = pvz2_base + offset;
  const datPtr: *volatile u64 = @ptrFromInt(targetAddr);
  const value = datPtr.*;

  log.info("DAT at 0x{X} is: 0x{X}", .{ targetAddr, value });
  return value;
}

/// Helper function to malloc objects via android standard lib
pub fn new(size: u64) *anyopaque {
  const ptr = androidStd.malloc(@intCast(size)) orelse {
    @panic("Out of memory while allocating object.");
  };
  return ptr;
}