pub const RtClass = extern struct {
  pub const SIZE = 0x48;

  vtable: *const VTable,    // offset 0x00
  name: [*:0]const u8,      // offset 0x08
  parent: ?*const *RtClass, // offset 0x10

  _padding: [SIZE - 18]u8,  // offset 0x18

  pub const offsets = struct {
    pub const ctor      = 0x00f382e8; // RtClass::RtClass
    pub const new       = 0x02349248; // new RtClass() or RtClass->new

    // VTable Function Addr
    pub const GetType       = 0x02349364; // RtClass::GetType
    pub const t_GetType     = 0x02349434; // RtClass::t_GetType
    pub const Dtor          = 0x0234a254; // RtClass::~RtClass
    pub const Destroy       = 0x0234989c; // RtClass::Destroy
    pub const IsTypeOf      = 0x02349298; // RtObject::IsTypeOf
    pub const Func5         = 0x023492cc; // RtObject::Func5
    pub const Serialize     = 0x02349f7c; // RtClass::Serialize
    pub const TypeOf        = 0x02349be4; // RtClass::TypeOf
    pub const RegisterClass = 0x02349c20; // RtClass::RegisterClass
  };

  pub const VTable = extern struct {
    GetType:       *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1:         *const fn (*anyopaque) callconv(.c) bool,
    Dtor:          *const fn (*anyopaque) callconv(.c) void,
    Destroy:       *const fn (*anyopaque) callconv(.c) void,
    IsTypeOf:      *const fn (*anyopaque) callconv(.c) void,
    Func5:         *const fn (*anyopaque) callconv(.c) i64,
    Serialize:     *const fn (*anyopaque) callconv(.c) void,
    TypeOf:        *const fn (*anyopaque) callconv(.c) bool,
    RegisterClass: *const fn (*anyopaque) callconv(.c) void,
  };
};