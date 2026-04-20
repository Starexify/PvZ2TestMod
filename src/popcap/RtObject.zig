const RtClass = @import("RtClass.zig");

pub const RtObject = extern struct {
  pub const SIZE = 0x8;

  vtable: *const VTable, // offset 0x00

  pub const offsets = struct {
    pub const RtObject_Definition = 0x02dc7bd0; // RtObject::RtObject_Definition

    pub const ctor      = 0x012abf00; // RtObject::RtObject
    pub const new       = 0x00f365f4; // new RtObject() or RtObject->new
    pub const s_GetType = 0x02349160; // RtObject::s_GetType

    // VTable Function Addr
    pub const GetType   = 0x023491d4; // RtObject::GetType
    pub const Func1     = 0x02349290; // RtObject::Func1
    pub const Dtor      = 0x0234a24c; // RtObject::~RtObject
    pub const Destroy   = 0x02df5028; // RtObject::Destroy
    pub const Func4     = 0x02349298; // RtObject::Func4
    pub const Func5     = 0x023492cc; // RtObject::Func5
    pub const Func6     = 0x023492d4; // RtObject::Func6

    pub const Dat1      = 0x02d53bd8; // RtObject::Dat1
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1:   *const fn (*anyopaque) callconv(.c) bool,
    Dtor:    *const fn (*anyopaque) callconv(.c) void,
    Destroy: *const fn (*anyopaque) callconv(.c) void,
    Func4:   *const fn (*anyopaque) callconv(.c) void,
    Func5:   *const fn (*anyopaque) callconv(.c) i64,
    Func6:   *const fn (*anyopaque) callconv(.c) i32,
  };
};