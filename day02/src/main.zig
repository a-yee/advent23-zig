const std = @import("std");
const regex = @import("regex");
const Regex = @import("regex").Regex;

const Game = struct {
    id: u32,
    red: u32,
    blue: u32,
    green: u32,
};

fn processColor(game: []u8, re: regex.Regex) !u32 {
    const cap: regex.Captures = try re.captures(game);
    return try std.fmt.parseInt(u32, cap.sliceAt(1).?, 10);
}

/// parseLine finds the game Id and max values for:
/// (r)ed
/// (g)reen
/// (b)lue
fn parseLine(line: []u8) !?Game {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    // For this fn assume all data structures will order colors in rgb order
    // 0 = red
    // 1 = green
    // 2 = blue
    // rgb for short
    var game: Game = .{
        .id = 0,
        .red = 0,
        .blue = 0,
        .green = 0,
    };

    // keep a positional marker so that we can process line in chunks without backtracking
    // Abuse the structure of data, all lines start with 'Game N:'
    var buf_idx: usize = for (line, 0..) |c, i| {
        if (c == ':') {
            break i + 1; // inc by 1 for next process
        }
    } else unreachable;

    // extract the game id N from buf processed so far
    var game_re = try Regex.compile(allocator, "^Game ([0-9]+):");
    const game_id_cap: ?regex.Captures = try game_re.captures(line[0..buf_idx]);
    if (game_id_cap) |id_cap| {
        game.id = try std.fmt.parseInt(u32, id_cap.sliceAt(1).?, 10);
    } else {
        return null; // invalid row
    }

    var rgb_re = [3]regex.Regex{
        try Regex.compile(allocator, "([0-9]+) red"),
        try Regex.compile(allocator, "([0-9]+) green"),
        try Regex.compile(allocator, "([0-9]+) blue"),
    };

    var rgb: [3]u32 = [3]u32{ 0, 0, 0 };
    rgb[0] = 1;

    var start: usize = buf_idx;
    while (buf_idx < line.len) : (buf_idx += 1) {
        // inc buf until you hit the round delimiter ';' or end of rounds
        if (buf_idx == line.len - 1 or line[buf_idx] == ';') {
            colors: for (0..3) |i| {
                const found: ?regex.Captures =
                    try rgb_re[i].captures(line[start .. buf_idx + 1]);
                var cubes: u32 = undefined;
                if (found) |cap| {
                    cubes = try std.fmt.parseInt(u32, cap.sliceAt(1).?, 10);
                } else {
                    continue :colors;
                }
                if (cubes > rgb[i]) {
                    rgb[i] = cubes;
                }
            }
            start = buf_idx;
        }
    }

    game.red = rgb[0];
    game.green = rgb[1];
    game.blue = rgb[2];

    return game;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    const rgb: [3]u32 = .{ 12, 13, 14 };

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const game: Game = try parseLine(line) orelse return;
        //std.debug.print("Game Id: {d}, red: {d}, green: {d}, blue: {d}\n", .{ game.id, game.red, game.green, game.blue });
        if (game.red <= rgb[0] and game.green <= rgb[1] and game.blue <= rgb[2]) {
            total += game.id;
        }
    }

    try stdout.print("Total: {d}\n", .{total});
}
