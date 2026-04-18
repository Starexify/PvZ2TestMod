const std = @import("std");

const NDK_SYSROOT = "/home/ImVeryBad/ToolKits/Android NDK/android-ndk-r27d/toolchains/llvm/prebuilt/linux-x86_64/sysroot";
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

    const aarch64_lib_path =NDK_SYSROOT ++ "/usr/lib/aarch64-linux-android/35";
    lib.addLibraryPath(.{ .cwd_relative = aarch64_lib_path });
    lib.linkSystemLibrary("log");
  }

  b.installArtifact(lib);
}