const HookUtil = @import("hookUtil.zig");
const RtObject = @import("./popcap/RTTI.zig").RtObject;
const RtClass = @import("./popcap/RTTI.zig").RtClass;
const log = @import("log.zig");

pub const BadObject = extern struct {
  parent: RtObject,
  data: u32,

  // Global Vars
  pub var BadObject_Def: ?*RtClass = null;
  var VTable: RtObject.VTable = undefined;

  pub fn init() void {
    if (BadObject_Def != null) return;

    const rtClassCtor = @as(*const fn (*RtClass) callconv(.c) void, @ptrFromInt(HookUtil.pvz2_base + RtClass.offsets.ctor));

    // Allocate metadata
    const rawNew = HookUtil.new(0x48);
    const def = @as(*RtClass, @ptrCast(@alignCast(rawNew)));

    rtClassCtor(def);

    const registerClass = @as(RtClass.RegisterClass, @ptrFromInt(HookUtil.pvz2_base + RtClass.offsets.RegisterClass));
    registerClass(
      def,
      "BadObject",
      RtObject.getGlobalDef(),
      @ptrCast(&BadObject.s_new)
    );

    const parentVTable = @as(*const RtObject.VTable, @ptrFromInt(HookUtil.pvz2_base + RtObject.offsets.VTable));
    VTable = parentVTable.*;
    VTable.GetType = getType; // Inject custom GetType function

    BadObject_Def = def;

    log.info("created BadObject class", .{});
  }

  pub fn s_new() callconv(.c) *BadObject {
    return BadObject.new();
  }

  pub fn new() *BadObject {
    const rawNew = HookUtil.new(@sizeOf(BadObject));
    const self = @as(*BadObject, @ptrCast(@alignCast(rawNew)));

    self.parent.vtable = &VTable;
    self.data = 1337;

    return self;
  }

  fn getType(self: *const RtObject) callconv(.c) *const RtClass {
    _ = self;
    return BadObject_Def.?;
  }
};