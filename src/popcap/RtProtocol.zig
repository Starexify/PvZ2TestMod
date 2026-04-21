const RtClass = @import("RtClass.zig");

pub const RtProtocol = extern struct {
  pub const SIZE = 0x8;

  vtable: *const VTable, // offset 0x00

  pub const offsets = struct {
    pub const ctor      = 0x0234a220; // RtProtocol::RtProtocol
    pub const new       = 0x0234a220; // new RtProtocol() or RtProtocol->new

    // VTable Function Addr
    pub const GetType   = 0x0234a144; // RtProtocol::GetType
    pub const t_GetType = 0x0234a21c; // RtProtocol::t_GetType
    pub const Func1     = 0x02349290; // RtProtocol::Func1
    pub const Dtor      = 0x0234a24c; // RtObject::~RtObject
    pub const Destroy   = 0x02df5028; // RtObject::Destroy
    pub const IsTypeOf  = 0x02349298; // RtObject::IsTypeOf
    pub const Func5     = 0x023492cc; // RtObject::Func5
    pub const Serialize = 0x023492d4; // RtObject::Serialize
  };

  pub const VTable = extern struct {
    GetType:   *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1:     *const fn (*anyopaque) callconv(.c) bool,
    Dtor:      *const fn (*anyopaque) callconv(.c) void,
    Destroy:   *const fn (*anyopaque) callconv(.c) void,
    IsTypeOf:  *const fn (*anyopaque) callconv(.c) bool,
    Func5:     *const fn (*anyopaque) callconv(.c) i64,
    Serialize: *const fn (*anyopaque) callconv(.c) i32,
  };
};