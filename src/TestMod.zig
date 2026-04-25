const std = @import("std");
const log = @import("log.zig");
const HookUtil = @import("hookUtil.zig");
const GameStateMgr = @import("popcap/GameStateMgr.zig").GameStateMgr;
const WorldMap = @import("popcap/WorldMap.zig").WorldMap;
const BadObject = @import("BadObject.zig").BadObject;
const RtObject = @import("popcap/RTTI.zig").RtObject;
const RtClass = @import("popcap/RTTI.zig").RtClass;

pub const Vec128 = extern struct {
  data: [16]u8,
};

pub const TestMod = struct {
  pub var originalDoStateChange: ?*anyopaque = null;
  pub var ogHandleTouchEnded: ?*anyopaque = null;
  pub var ogHandleEndOfLevel: ?*anyopaque = null;
  pub var ogExitZenGardenHook: ?*anyopaque = null;

  pub fn init() void {
    initClasses();
    initHooks();
  }

  pub fn initClasses() void {
    log.info("Registering Classes...", .{});

    BadObject.init();

    const myObj = BadObject.new();
    log.info("new BadObject created at 0x{X} and data 0x{X}", .{@intFromPtr(myObj), myObj.data});
    _ = checkObj(myObj);
  }

  pub fn checkObj(obj: *BadObject) bool {
    const object_ptr = @as(*RtObject, @ptrCast(obj));

    const vtable = object_ptr.vtable;
    const isBadObj = vtable.IsTypeOf(object_ptr, BadObject.BadObject_Def.?);
    const isRtObj = vtable.IsTypeOf(object_ptr, RtObject.getGlobalDef());

    log.info("IsTypeOf(BadObject): {}", .{isBadObj});
    log.info("IsTypeOf(RtObject): {}", .{isRtObj});

    return isBadObj;
  }

  pub fn initHooks() void {
    log.info("Registering Hooks...", .{});

    //HookUtil.hookFunction(PvZ2Debug.offsets.Log, &pvz2LogHook, &originalLog);

    HookUtil.hookFunction(WorldMap.offsets.handleTouchEnded, &handleTouchEndedHook, &ogHandleTouchEnded);

    HookUtil.hookFunction(GameStateMgr.offsets.handleEndOfLevel, &handleEndOfLevelHook, &ogHandleEndOfLevel);
    HookUtil.hookFunction(GameStateMgr.offsets.DoStateChange, &doStateChangeHook, &originalDoStateChange);
    HookUtil.hookFunction(GameStateMgr.offsets.ExitZenGarden, &exitZenGardenHook, &ogExitZenGardenHook);

    // const Class_Def = HookUtil.getDat(0x02dc7ce0);
    // if (Class_Def != 0) {
    //   log.info("RtObject_Def = 0x{X}", .{Class_Def});
    //
    //   const namePtr = @as(*u64, @ptrFromInt(Class_Def + 8)).*;
    //   const name = std.mem.span(@as([*c]const u8, @ptrFromInt(namePtr)));
    //   log.info("Class found: {s}", .{name});
    // }
  }

  fn handleTouchEndedHook(
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: *isize,
    p10: i32,
    p11: u64,
    p12: *anyopaque,
    p13: *anyopaque,
    p14: *u16,
    p15: u64,
    p16: u64
  ) callconv(.c) void {
    log.info("WorldMap::handleTouchEndedHook called!", .{});
    WorldMap.handleTouchEnded(ogHandleTouchEnded, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
  }

  /// State Manager Hook
  fn doStateChangeHook(self: *GameStateMgr,
    p2: u32,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64
  ) callconv(.c) void {
    log.info("called GameStateMgr::doStateChangeHook({d}, {d}, {d}, {d}, {d}, {d}, {d})", .{p2, p3, p4, p5, p6, p7, p8});
    GameStateMgr.DoStateChange(originalDoStateChange, self, p2, p3, p4, p5, p6, p7, p8);
  }

  /// State End Of Level Hook
  fn handleEndOfLevelHook(
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: isize,
    p10: u64,
    p11: **anyopaque,
    p12: *u8,
    p13: **usize,
    p14: u64,
    p15: *anyopaque,
    p16: u64
  ) callconv(.c) void {
    log.info("called GameStateMgr::ShandleEndOfLevelHook called!", .{});
    GameStateMgr.handleEndOfLevel(ogHandleEndOfLevel, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
  }

  fn exitZenGardenHook(
    p1: Vec128,
    p2: Vec128,
    p3: u64,
    p4: u64,
    p5: u64,
    p6: u64,
    p7: u64,
    p8: u64,
    p9: isize,
    p10: u32,
    p11: usize,
    p12: u64,
    p13: **usize,
    p14: u64,
    p15: *anyopaque,
    p16: u64
  ) callconv(.c) void {
    log.info("called GameStateMgr::ExitZenGarden called!", .{});
    GameStateMgr.ExitZenGarden(ogExitZenGardenHook, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16);
  }
};