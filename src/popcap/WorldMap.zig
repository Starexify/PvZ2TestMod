const Vec128 = @import("../TestMod.zig").Vec128;

pub const WorldMap = opaque {
  pub fn handleTouchEnded(
    originalPtr: ?*anyopaque,
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: *isize,
    p10: i32,
    p11: u64,
    p12: *anyopaque,
    p13: *anyopaque,
    p14: *u16,
    p15: u64,
    p16: u64
  ) void {
    if (originalPtr) |ptr| {
      const orig: *const fn (Vec128, Vec128, u64, u64, u64, u64, u64, u64, *isize, i32, u64, *anyopaque, *anyopaque, *u16, u64, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
    }
  }

  pub const offsets = struct {
    pub const handleTouchEnded = 0x011d2764;
  };
};