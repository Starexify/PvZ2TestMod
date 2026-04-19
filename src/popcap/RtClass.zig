const RtObject = @import("RtObject.zig");

const RtClass = extern struct { // size 0x48
  vtable: *const RtClassVTable,
};

const RtClassVTable = struct {
  GetType: *const fn (*anyopaque) callconv(.C) *RtClass,
  Func1: *const fn (*anyopaque) callconv(.C) void,
  Func2: *const fn (*anyopaque) callconv(.C) void,
  Func3: *const fn (*anyopaque) callconv(.C) void,
  Func4: *const fn (*anyopaque) callconv(.C) void,
  Func5: *const fn (*anyopaque) callconv(.C) void,
  Func6: *const fn (*anyopaque) callconv(.C) void,
  Func7: *const fn (*anyopaque) callconv(.C) void,
  Func8: *const fn (*anyopaque) callconv(.C) void,
};