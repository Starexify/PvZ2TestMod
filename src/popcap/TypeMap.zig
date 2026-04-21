const RtClass = @import("RtClass.zig");

pub const TypeMap = struct {
  pub const RtObject_Def:   *?*RtClass = @ptrFromInt(0x02dc7bd0);
  pub const RtUnit_Def:     *?*RtClass = @ptrFromInt(0x02dc7bd8);
  pub const RtProtocol_Def: *?*RtClass = @ptrFromInt(0x02dc7c58);
};