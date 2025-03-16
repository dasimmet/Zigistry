const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{
        .preferred_optimize_mode = std.builtin.OptimizeMode.ReleaseFast,
    });
    // Helper Functions Library
    const helperFunctions = b.addModule("helperFunctions", .{
        .root_source_file = b.path("scripts/libs/functionsProvider.zig"),
        .target = target,
        .optimize = optimize,
    });
    {
        const db_exe = b.addExecutable(.{
            .name = "db",
            .root_source_file = b.path("scripts/db.zig"),
            .target = target,
            .optimize = optimize,
        });
        db_exe.linkSystemLibrary("c");
        db_exe.root_module.addImport("helperFunctions", helperFunctions);
        b.installArtifact(db_exe);

        const dbRunCmd = b.addRunArtifact(db_exe);
        dbRunCmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            dbRunCmd.addArgs(args);
        }
        const dbRunStep = b.step("run_db", "usage: zig build run_db [-h|--help] <subcommand>");
        dbRunStep.dependOn(&dbRunCmd.step);
    }
    // Helper Functions Unit Tests
    {
        const functionsProviderUnitTests = b.addTest(.{
            .root_source_file = b.path("scripts/libs/functionsProvider.zig"),
            .target = target,
            .optimize = optimize,
        });
        functionsProviderUnitTests.linkSystemLibrary("c");
        const runFunctionsProviderUnitTests = b.addRunArtifact(functionsProviderUnitTests);
        const functionsProviderTestStep = b.step("run_testlib", "Run helperFunctions lib tests");
        functionsProviderTestStep.dependOn(&runFunctionsProviderUnitTests.step);
    }
}
