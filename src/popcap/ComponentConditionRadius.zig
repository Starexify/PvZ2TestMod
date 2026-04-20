const RtClass = @import("RtClass.zig");

pub const ComponentConditionRadius = extern struct {
  pub const SIZE = 0x1a0;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    pub const ctor = 0x012abf00; // ComponentConditionRadius::ComponentConditionRadius
    pub const new   = 0x00f365f4; // new ComponentConditionRadius() or ComponentConditionRadius->new

    pub const GetType = 0x012aef5c; // ComponentConditionRadius::GetType
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
  };
};