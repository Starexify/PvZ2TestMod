pub const NetworkServiceManager = opaque {
  pub fn Connect(
    originalPtr: ?*anyopaque,
    p1: *anyopaque, p2: u64, p3: u64, p4: u64, p5: u64,
    p6: u64, p7: u64, p8: u64, p9: u64, p10: u64,
    param_11: i32,
    p12: *anyopaque, p13: *anyopaque, p14: *anyopaque, p15: u64, p16: u64
  ) i32 {
    if (originalPtr) |ptr| {
      const orig: *const fn (*anyopaque, u64, u64, u64, u64, u64, u64, u64, u64, u64, i32, *anyopaque,  *anyopaque, *anyopaque, u64, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, param_11, p12, p13, p14, p15, p16);
    }
    return -1;
  }

  pub const offsets = struct {
    pub const Connect = 0x02267bc8;
  };
};