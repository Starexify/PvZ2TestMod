const std = @import("std");

const NDK_SYSROOT_PATH = "/home/ImVeryBad/ToolKits/Android NDK/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/sysroot";

const APK_DECOMP_PATH = "/home/ImVeryBad/Modding/PvZ2/13.0.1/com.ea.game.pvz2_row_13.0.1-1042_minAPI24(arm64-v8a,armeabi-v7a)(nodpi)";
const APKTOOL_PATH = "/home/ImVeryBad/.apklab/apktool_3.0.1.jar";
const SIGNER_PATH = "/home/ImVeryBad/.apklab/uber-apk-signer-1.3.0.jar";

pub fn build(b: *std.Build) void {
  const target = b.standardTargetOptions(.{});
  const optimize = b.standardOptimizeOption(.{});

  const lib = b.addLibrary(.{
    .name = "Mod",
    .root_module = b.createModule(.{
      .root_source_file = b.path("src/main.zig"),
      .target = target,
      .optimize = optimize,
      .pic = true,
    }),
    .linkage = .dynamic,
  });

  if (target.result.os.tag == .linux and target.result.abi == .android) {
    lib.setLibCFile(b.path("libc.txt"));

    const aarch64_lib_path =NDK_SYSROOT_PATH ++ "/usr/lib/aarch64-linux-android/35";
    lib.addLibraryPath(.{ .cwd_relative = aarch64_lib_path });
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
  install_lib.addArg(b.fmt("{s}/lib/arm64-v8a/libMod.so", .{APK_DECOMP_PATH}));

  // Build APK
  const apk_build = b.addSystemCommand(&.{ "java", "-jar", APKTOOL_PATH, "b", APK_DECOMP_PATH });
  apk_build.step.dependOn(&install_lib.step);

  // Sign APK
  const apk_sign = b.addSystemCommand(&.{
    "java", "-jar", SIGNER_PATH,
    "-a", b.fmt("{s}/dist", .{APK_DECOMP_PATH}),
    "--overwrite", "--allowResign"
  });
  apk_sign.step.dependOn(&apk_build.step);

  // Install via ADB
  const final_apk_path = b.fmt("{s}/dist/com.ea.game.pvz2_bad_13.0.1-1042_minAPI24(arm64-v8a,armeabi-v7a)(nodpi).apk", .{APK_DECOMP_PATH});
  const adb_install = b.addSystemCommand(&.{ "adb", "install", "-r", final_apk_path });
  adb_install.step.dependOn(&apk_sign.step);

  // Launch Game
  const launch_game = b.addSystemCommand(&.{
    "adb", "shell", "monkey", "-p", "com.ea.game.pvz2_bad", "1"
  });
  launch_game.step.dependOn(&adb_install.step);

  // Start Logcat
  const log_cmd = b.addSystemCommand(&.{
    "adb", "logcat", "PVZ2_MOD:V", "DEBUG:V", "*:S" // "AndroidRuntime:E",
  });
  log_cmd.step.dependOn(&launch_game.step);
  deploy_step.dependOn(&log_cmd.step);

  const log_step = b.step("logs", "Stream mod logs from the device");
  log_step.dependOn(&log_cmd.step);
}