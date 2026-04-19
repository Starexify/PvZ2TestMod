const RtClass = @import("RtClass.zig");

const RtObject = extern struct { // size: 0x8
  vtable: *const RtObjectVTable, // offset 0x00
};

const RtObjectVTable = extern struct {

};