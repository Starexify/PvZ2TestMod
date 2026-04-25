const HookUtil = @import("../hookUtil.zig");

pub const RtObject = extern struct {
  pub const SIZE = 0x8;

  vtable: *const VTable, // offset 0x0

  pub const VTable = extern struct {
    GetType:        *const fn (self: *const RtObject) callconv(.c) *const RtClass,              // 0x00
    Func1:          *const fn (self: *const RtObject) callconv(.c) bool,                        // 0x08
    Dtor:           *const fn (self: *const RtObject) callconv(.c) void,                        // 0x10
    Destroy:        *const fn (self: *const RtObject) callconv(.c) void,                        // 0x18
    IsTypeOf:       *const fn (self: *const RtObject, other: *const RtClass) callconv(.c) bool, // 0x20
    Func5:          *const anyopaque,  // 0x28
    Serialize:      *const anyopaque,  // 0x30
  };

  pub const offsets = struct {
    pub const RtObject_Def = 0x02dc7bd0;
    pub const VTable       = 0x02c53b38;
  };

  pub fn getGlobalDef() *const RtClass {
    const func = @as(*const fn () callconv(.c) *const RtClass, @ptrFromInt(HookUtil.pvz2_base + 0x023491d4));
    return func();
  }
};

pub const RtClass = extern struct {
  pub const SIZE = 0x48;

  vtable:   *const VTable,    // offset 0x00
  name:     [*:0]const u8,    // offset 0x08
  _padding: [SIZE - 0x10]u8,  // offset 0x10

  pub const VTable = extern struct {
    t_GetType:      *const fn (self: *const RtClass) callconv(.c) *const RtClass,              // 0x00
    Func1:          *const fn (self: *const RtClass) callconv(.c) bool,                        // 0x08
    Dtor:           *const fn (self: *const RtClass) callconv(.c) void,                        // 0x10
    Destroy:        *const fn (self: *const RtClass) callconv(.c) void,                        // 0x18
    IsTypeOf:       *const fn (self: *const RtClass, other: *const RtClass) callconv(.c) bool, // 0x20
    Func5:          *const anyopaque,  // 0x28
    Serialize:      *const anyopaque,  // 0x30
    TypeOf:         *const anyopaque,  // 0x38
    RegisterClass:  *const anyopaque,  // 0x40
  };

  pub const RegisterClass = *const fn (
    metadata: *RtClass,
    name: [*c]const u8,
    parent: *const RtClass,
    allocator: *const anyopaque
  ) callconv(.c) void;

  pub const offsets = struct {
    pub const RtClass_Def   = 0x02dc7bd8;
    pub const VTable        = 0x02c53b80;
    pub const ctor          = 0x023496b0; // RtClass::RtClass

    pub const RegisterClass = 0x02349c20;
  };
};
