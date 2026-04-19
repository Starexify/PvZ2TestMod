const std = @import("std");

/// Custom Paths.
/// These should be changed on different setups!!
const MOD_TAG = "PVZ2_MOD";
const HOME_PATH = "/home/ImVeryBad/";
const NDK_PATH = HOME_PATH ++ "ToolKits/Android NDK/android-ndk-r27d";
const ANDROID_PKG = "com.ea.game.pvz2_bad";
const APK_PATH = "com.ea.game.pvz2_bad_13.0.1-1042_minAPI24(arm64-v8a,armeabi-v7a)(nodpi)";
const APK_DECOMP_PATH = HOME_PATH ++ "Modding/PvZ2/13.0.1/" ++ APK_PATH;

const NDK_SYSROOT_PATH = NDK_PATH ++ "/toolchains/llvm/prebuilt/linux-x86_64/sysroot";
const NDK_ANDROID_API_PATH = NDK_SYSROOT_PATH ++ "/usr/lib/aarch64-linux-android/35";
const NDK_INCLUDE_PATH = NDK_SYSROOT_PATH ++ "/usr/include";
const NDK_aarch64_PATH = NDK_INCLUDE_PATH ++ "/aarch64-linux-android";

const APKTOOL_PATH = HOME_PATH ++ ".apklab/apktool_3.0.1.jar";
const SIGNER_PATH = HOME_PATH ++ ".apklab/uber-apk-signer-1.3.0.jar";

const SHADOWHOOK_PATH = "libs/android-inline-hook/shadowhook/src/main/cpp";
const SHADOWHOOK_INCLUDE_PATH = SHADOWHOOK_PATH ++ "/include";

pub fn build(b: *std.Build) void {
  const target = b.standardTargetOptions(.{
    .default_target = .{
      .cpu_arch = .aarch64,
      .os_tag = .linux,
      .abi = .android,
      .android_api_level = 35
    }
  });
  const optimize = .ReleaseSmall;

  // Compile ShadowHook
  const shadowhook = b.addLibrary(.{
    .name = "shadowhook",
    .root_module = b.createModule(.{
      .target = target,
      .optimize = optimize,
      .link_libc = true
    }),
    .linkage = .static
  });

  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/include"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/common"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/arch/arm64"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/third_party/xdl/include"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/third_party/bsd"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/third_party/xdl"));
  shadowhook.addIncludePath(b.path(SHADOWHOOK_PATH ++ "/third_party/lss"));
  shadowhook.addSystemIncludePath(.{ .cwd_relative = NDK_INCLUDE_PATH });
  shadowhook.addSystemIncludePath(.{ .cwd_relative = NDK_aarch64_PATH });

  shadowhook.addCSourceFiles(.{
    .root = b.path(SHADOWHOOK_PATH),
    .files = &.{
      "shadowhook.c",
      "sh_hub.c",
      "sh_safe.c",
      "sh_switch.c",
      "sh_recorder.c",
      "sh_elf.c",
      "sh_enter.c",
      "sh_island.c",
      "sh_jni.c",
      "sh_linker.c",
      "sh_task.c",
      "sh_xdl.c",

      "common/bytesig.c",
      "common/sh_log.c",
      "common/sh_errno.c",
      "common/sh_ref.c",
      "common/sh_trampo.c",
      "common/sh_util.c",

      "arch/arm64/sh_inst.c",
      "arch/arm64/sh_a64.c",

      "third_party/xdl/xdl.c",
      "third_party/xdl/xdl_iterate.c",
      "third_party/xdl/xdl_linker.c",
      "third_party/xdl/xdl_lzma.c",
      "third_party/xdl/xdl_util.c",
    },
  });
  shadowhook.addCSourceFile(.{
    .file = b.path(SHADOWHOOK_PATH ++ "/arch/arm64/sh_glue.S"),
  });

  const lib = b.addLibrary(.{
    .name = "Mod",
    .root_module = b.createModule(.{
      .root_source_file = b.path("src/main.zig"),
      .target = target,
      .optimize = optimize,
      .link_libc = true,
      .pic = true
    }),
    .linkage = .dynamic,
  });

  lib.addIncludePath(b.path(SHADOWHOOK_PATH));
  lib.addIncludePath(b.path(SHADOWHOOK_INCLUDE_PATH));
  lib.linkLibrary(shadowhook);

  if (target.result.os.tag == .linux and target.result.abi == .android) {
    lib.setLibCFile(b.path("libc.txt"));
    lib.addLibraryPath(.{ .cwd_relative = NDK_ANDROID_API_PATH });
    lib.linkSystemLibrary("log");
  }

  b.installArtifact(lib);

  buildAPK(b, lib);
}

/// Build APK
pub fn buildAPK(b: *std.Build, lib: *std.Build.Step.Compile) void {
  const deploy_step = b.step("deploy", "Copy the built library to the decompiled APK folder");

  const install_lib = b.addSystemCommand(&.{ "cp" });
  install_lib.addArtifactArg(lib);
  install_lib.addArg(APK_DECOMP_PATH ++ "/lib/arm64-v8a/libMod.so");

  // Build APK
  const apk_build = b.addSystemCommand(&.{ "java", "-jar", APKTOOL_PATH, "b", APK_DECOMP_PATH });
  apk_build.step.dependOn(&install_lib.step);

  // Sign APK
  const apk_sign = b.addSystemCommand(&.{
    "java", "-jar", SIGNER_PATH,
    "-a", APK_DECOMP_PATH ++ "/dist",
    "--overwrite", "--allowResign"
  });
  apk_sign.step.dependOn(&apk_build.step);

  // Install via ADB
  const final_apk_path = APK_DECOMP_PATH ++ "/dist/" ++ APK_PATH ++ ".apk";
  const adb_install = b.addSystemCommand(&.{
    "adb", "install", "-r", final_apk_path
  });
  adb_install.step.dependOn(&apk_sign.step);

  // Launch Game
  const launch_game = b.addSystemCommand(&.{
    "adb", "shell", "monkey", "-p", ANDROID_PKG, "1"
  });
  launch_game.step.dependOn(&adb_install.step);

  // Start Logcat
  const log_cmd = b.addSystemCommand(&.{
    "adb", "logcat", MOD_TAG++":V", "DEBUG:V", "*:S" // "AndroidRuntime:E",
  });
  log_cmd.step.dependOn(&launch_game.step);
  deploy_step.dependOn(&log_cmd.step);

  const log_step = b.step("logs", "Stream mod logs from the device");
  log_step.dependOn(&log_cmd.step);
}