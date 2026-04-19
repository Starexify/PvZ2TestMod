const std = @import("std");

/// Custom Paths.
/// These should be changed on different setups!!
const MOD_TAG = "PVZ2_MOD";
const HOME_PATH = "/home/ImVeryBad/";
const NDK_PATH = HOME_PATH ++ "ToolKits/Android NDK/android-ndk-r27d";
const ANDROID_PKG = "com.ea.game.pvz2_bad";
const APK_PATH = "com.ea.game.pvz2_bad_13.0.1-1042_minAPI24(arm64-v8a,armeabi-v7a)(nodpi)";
const APK_DECOMP_PATH = HOME_PATH ++ "Modding/PvZ2/13.0.1/" ++ APK_PATH;

/// Android NDK
const ANDROID_API = 35;
const NDK_SYSROOT_PATH = NDK_PATH ++ "/toolchains/llvm/prebuilt/linux-x86_64/sysroot";
const NDK_ANDROID_API_PATH = NDK_SYSROOT_PATH ++ "/usr/lib/aarch64-linux-android/" ++ std.fmt.comptimePrint("{d}", .{ANDROID_API});
const NDK_INCLUDE_PATH = NDK_SYSROOT_PATH ++ "/usr/include";
const NDK_aarch64_PATH = NDK_INCLUDE_PATH ++ "/aarch64-linux-android";

// APK Tool Paths (Using the .apklab VSCode extension utils)
const APKTOOL_PATH = HOME_PATH ++ ".apklab/apktool_3.0.1.jar";
const SIGNER_PATH = HOME_PATH ++ ".apklab/uber-apk-signer-1.3.0.jar";

// Dobby lib Path
const AND64_PATH = "libs/And64InlineHook//";

pub fn build(b: *std.Build) void {
  const target = b.standardTargetOptions(.{
    .default_target = .{
      .cpu_arch = .aarch64,
      .os_tag = .linux,
      .abi = .android,
      .android_api_level = ANDROID_API
    }
  });
  const optimize = .ReleaseSmall;

  const lib = b.addLibrary(.{
    .name = "Mod",
    .root_module = b.createModule(.{
      .root_source_file = b.path("src/main.zig"),
      .target = target,
      .optimize = optimize,
      .link_libc = true,
      .link_libcpp = true,
      .pic = true
    }),
    .linkage = .dynamic,
  });

  lib.addCSourceFile(.{
    .file = b.path(AND64_PATH ++ "/And64InlineHook.cpp"),
    .flags = &.{ "-std=c++11" },
  });
  lib.addIncludePath(b.path(AND64_PATH));

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