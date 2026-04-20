const RtClass = @import("RtClass.zig");

pub const ZombieZombossMech_Dark = extern struct {
  pub const SIZE = 0x568;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    // pub const ctor = 0x015425a0; // ZombieZombossMech_Dark::ZombieZombossMech_Dark
    pub const new   = 0x015425a4; // new ZombieZombossMech_Dark() or ZombieZombossMech_Dark->new

    pub const GetType = 0x015424f8; // ZombieZombossMech_Dark::GetType
    pub const t_GetType = 0x015425a0; // ZombieZombossMech_Dark::t_GetType
    pub const Func1 = 0x015428f0; // ZombieZombossMech_Dark::Func1
    pub const Dtor = 0x0164c26c; // ZombieZombossMech_Dark::~ZombieZombossMech_Dark
    pub const Destroy = 0x01640358; // ZombieZombossMech_Dark::Destroy
  };

  pub const VTable = extern struct {
    t_GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1: *const fn (*anyopaque) callconv(.c) i64,
    Dtor: *const fn (*anyopaque) callconv(.c) void,
    Destroy: *const fn (*anyopaque) callconv(.c) void,
  };
};