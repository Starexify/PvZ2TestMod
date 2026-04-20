const RtObject = @import("RtObject.zig");

const RtClass = extern struct { // size 0x48
  vtable: *const RtClassVTable,
};

const RtClassVTable = struct {
  GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
  Func1: *const fn (*anyopaque) callconv(.c) void,
  Func2: *const fn (*anyopaque) callconv(.c) void,
  Func3: *const fn (*anyopaque) callconv(.c) void,
  Func4: *const fn (*anyopaque) callconv(.c) void,
  Func5: *const fn (*anyopaque) callconv(.c) void,
  Func6: *const fn (*anyopaque) callconv(.c) void,
  Func7: *const fn (*anyopaque) callconv(.c) void,
  Func8: *const fn (*anyopaque) callconv(.c) void,
};