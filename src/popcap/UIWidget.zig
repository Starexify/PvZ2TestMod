const RtClass = @import("RtClass.zig");

pub const UIWidget = extern struct {
  pub const SIZE = 0x1a0;

  vtable: *const VTable, // offset 0x00
  _padding: [SIZE - 8]u8, // offset 0x08

  pub const offsets = struct {
    pub const ctor = 0x00f382e8; // UIWidget::UIWidget
    pub const alloc   = 0x00f365f4; // new UIWidget() or UIWidget->Alloc
    pub const s_GetType   = 0x00f36534; // UIWidget->s_GetType

    pub const GetType = 0x00f36594; // UIWidget::GetType
    pub const Func1 = 0x00f37044; // UIWidget::Func1
    pub const Dtor = 0x00f38508; // UIWidget::~UIWidget
    pub const Destroy = 0x00f38694; // UIWidget::Destroy
  };

  pub const VTable = extern struct {
    GetType: *const fn (*anyopaque) callconv(.c) *RtClass,
    Func1: *const fn (*anyopaque) callconv(.c) i64,
    Dtor: *const fn (*anyopaque) callconv(.c) void,
    Destroy: *const fn (*anyopaque) callconv(.c) void,
  };
};