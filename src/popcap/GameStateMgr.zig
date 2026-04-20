pub const GameStateMgr = opaque {
  pub fn DoStateChange(self: *GameStateMgr, originalPtr: ?*anyopaque, param2: u32, p3: u64, p4: u64, p5: u64, p6: u64, p7: u64, p8: u64) void {
    if (originalPtr) |ptr| {
      const orig: *const fn (*GameStateMgr, u32, u64, u64, u64, u64, u64, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(self, param2, p3, p4, p5, p6, p7, p8);
    }
  }

  pub const offsets = struct {
    pub const DoStateChange = 0x0171d9fc;
  };
};