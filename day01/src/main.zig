const std = @import("std");
const ascii = std.ascii;
const debug = std.debug;

fn findCoordinate(line: []u8) !u32 {
    var v: [2]u8 = undefined;
    v[0] = for (line) |c| {
        if (ascii.isDigit(c)) {
            break c;
        }
    } else unreachable;

    var i: usize = line.len - 1;
    v[1] = while (i >= 0) : (i -= 1) {
        if (ascii.isDigit(line[i])) {
            break line[i];
        }
    };
    return std.fmt.parseInt(u32, &v, 10);
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const file = try std.fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var total: u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (findCoordinate(line)) |coordinate| {
            total += coordinate;
        } else |err| {
            try stdout.print("{}\n", .{err});
        }
    }
    try stdout.print("{d}\n", .{total});
}
