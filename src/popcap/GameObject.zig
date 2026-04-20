const RtClass = @import("RtClass.zig");

pub const GameObject = extern struct {
  pub const SIZE = 0x10;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    pub const ctor = 0x012abf00; // GameObject::GameObject
    pub const new   = 0x00f365f4; // new GameObject() or GameObject->new
    pub const s_GetType = 0x012ae01c; // GameObject::s_GetType

    pub const GetType = 0x012ae07c; // GameObject::GetType
    pub const Func1 = 0x012ae290; // GameObject::Func1
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1: *const fn (*anyopaque) callconv(.c) void,
  };
};