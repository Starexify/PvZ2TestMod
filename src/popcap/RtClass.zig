pub const RtClass = extern struct {
  pub const SIZE = 0x48;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    pub const RtClass_Definition = 0x02dc7bd0; // RtObject::RtObject_Definition

    pub const ctor      = 0x00f382e8; // RtClass::RtClass
    pub const new       = 0x02349248; // new RtClass() or RtClass->new

    // VTable Function Addr
    pub const GetType   = 0x02349364; // RtClass::GetType
    pub const t_GetType = 0x02349434; // RtClass::t_GetType
    pub const Dtor      = 0x02349434; // RtClass::~RtClass
    pub const Destroy   = 0x02349434; // RtClass::Destroy
    pub const Func4     = 0x02349298; // RtObject::Func4
    pub const Func5     = 0x023492cc; // RtObject::Func5
    pub const Func6     = 0x02349f7c; // RtClass::Func6
    pub const Func7     = 0x02349be4; // RtClass::Func7
    pub const Func8     = 0x02349c20; // RtClass::Func8
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1:   *const fn (*anyopaque) callconv(.c) bool,
    Dtor:    *const fn (*anyopaque) callconv(.c) void,
    Destroy: *const fn (*anyopaque) callconv(.c) void,
    Func4:   *const fn (*anyopaque) callconv(.c) void,
    Func5:   *const fn (*anyopaque) callconv(.c) i64,
    Func6:   *const fn (*anyopaque) callconv(.c) void,
    Func7:   *const fn (*anyopaque) callconv(.c) bool,
    Func8:   *const fn (*anyopaque) callconv(.c) void,
  };
};