const std = @import("std");
const codeberg = @import("codeberg.zig");
const gitlab = @import("gitlab.zig");
const databaseCompiler = @import("databaseCompiler.zig");
const databaseCompiler2 = @import("databaseCompiler2.zig");
const repoListCompressor = @import("repoListCompressor.zig");
const createDeepSearchDB = @import("createDeepSearchDB.zig");

const commands = &.{
    .{ "checkout-db", checkout },
    .{ "store-db", store_db },
    .{ "databaseCompiler", databaseCompiler.main },
    .{ "databaseCompiler2", databaseCompiler2.main },
    .{ "codeberg", codeberg.main },
    .{ "gitlab", gitlab.main },
    .{ "repoListCompressor", repoListCompressor.main },
    .{ "createDeepSearchDB", createDeepSearchDB.main },
};

pub fn usage() void {
    std.io.getStdErr().writeAll(
        \\usage: db [-h|--help] <subcommand>
        \\
        \\available subcommands:
        \\
        \\
    ) catch unreachable;
}

pub fn main() !void {
    var gpa_data = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_data.deinit();
    const gpa = gpa_data.allocator();
    const args = try std.process.argsAlloc(gpa);
    defer std.process.argsFree(gpa, args);
    if (args.len < 2 or std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h")) {
        usage();
        inline for (commands) |cmd| {
            try std.io.getStdErr().writeAll(cmd[0]++"\n");
        }
        std.process.exit(1);
    }
    inline for (commands) |cmd| {
        if (std.mem.eql(u8, cmd[0], args[1])) {
            std.log.info("i: {s} {s}", .{ cmd[0], args[1] });
            return cmd[1]();
        }
    }
    @panic("unknown command");
}

pub fn cli(cmds: []const []const []const u8) !void {
    var gpa_data = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa_data.deinit();
    const gpa = gpa_data.allocator();
    for (cmds) |cmd| {
    
        const res = try std.process.Child.run(.{
            .allocator = gpa,
            .argv = cmd,
        });
        defer gpa.free(res.stdout);
        defer gpa.free(res.stderr);
        std.log.info("{s}", .{res.stdout});
        if (res.stderr.len > 0) std.log.err("{s}", .{res.stderr});
    
    }
}

pub fn checkout() !void {
    return cli(&.{
        &.{"git", "checkout", "database", "--", "database"},
        &.{"git", "rm", "-r", "--cached", "database"},
    });
}

pub fn store_db() !void {
    return cli(&.{
        &.{"git", "checkout", "database"},
        &.{"git", "add", "database"},
        &.{"git", "commit", "-m", "Updated Database"},
    });
}
