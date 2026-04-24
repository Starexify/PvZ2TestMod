const Vec128 = @import("../TestMod.zig").Vec128;

pub const GameStateMgr = opaque {
  pub fn DoStateChange(originalPtr: ?*anyopaque, self: *GameStateMgr, p2: u32, p3: u64, p4: u64, p5: u64, p6: u64, p7: u64, p8: u64) void {
    if (originalPtr) |ptr| {
      const orig: *const fn (*GameStateMgr, u32, u64, u64, u64, u64, u64, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(self, p2, p3, p4, p5, p6, p7, p8);
    }
  }

  pub fn handleEndOfLevel(
    originalPtr: ?*anyopaque,
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: isize,
    p10: u64,
    p11: **anyopaque,
    p12: *u8,
    p13: **usize,
    p14: u64,
    p15: *anyopaque,
    p16: u64
  ) void {
    if (originalPtr) |ptr| {
      const orig: *const fn (Vec128, Vec128, u64, u64, u64, u64, u64, u64, isize, u64, **anyopaque, *u8, **usize, u64, *anyopaque, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
    }
  }

  pub fn ExitZenGarden(
    originalPtr: ?*anyopaque,
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: isize,
    p10: u32,
    p11: usize,
    p12: u64,
    p13: **usize,
    p14: u64,
    p15: *anyopaque,
    p16: u64
  ) void {
    if (originalPtr) |ptr| {
      const orig: *const fn (Vec128, Vec128, u64, u64, u64, u64, u64, u64, isize, u32, usize, u64, **usize, u64, *anyopaque, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
    }
  }

  pub const offsets = struct {
    pub const DoStateChange    = 0x0171d9fc;
    pub const ExitZenGarden    = 0x0171cba8;
    pub const handleEndOfLevel = 0x01722258;
  };
};