pub const PvZ2Debug = opaque {
  pub fn Log(
    originalPtr: ?*anyopaque,
    fmt: [*:0]const u8,
    p1: u64, p2: u64, p3: u64, p4: u64, p5: u64, p6: u64, p7: u64
  ) void {
    if (originalPtr) |ptr| {
      const orig: *const fn ([*:0]const u8, u64, u64, u64, u64, u64, u64, u64) callconv(.c) void = @ptrCast(@alignCast(ptr));
      orig(fmt, p1, p2, p3, p4, p5, p6, p7);
    }
  }

  pub const offsets = struct {
    pub const Log = 0x02203050;
  };
};