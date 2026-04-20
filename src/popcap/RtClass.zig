pub const RtClass = extern struct {
  pub const SIZE = 0x48;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    pub const ctor = 0x00f382e8; // RtClass::RtClass
    pub const new   = 0x02349248; // new RtClass() or RtClass->new
    pub const t_GetType = 0x02349434; // RtClass::t_GetType

    pub const GetType = 0x02349364; // RtClass::GetType
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
  };
};