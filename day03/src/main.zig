const std = @import("std");

// Need to get window - and which line are you parsing
// max row length, can determine within the function

fn partNrSearch(window: [3][]u8, line_length: usize) !void {
    const stdout = std.io.getStdOut().writer();

    for (0..window.len) |i| {
        try stdout.print("{s}\n", .{window[i][0..line_length]});
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const file = try std.fs.cwd().openFile("example.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    const bufSize = 1024;
    const windowMax = 3;
    var buf: [windowMax][1024]u8 = undefined;
    for (0..bufSize) |i| {
        buf[0][i] = '.';
    }
    var active: usize = 1;
    var line_nr: usize = 0;

    // for this problem we are going to abuse the fact that all lines are same length
    while (try in_stream.readUntilDelimiterOrEof(&buf[active], '\n')) |line| : //
    (line_nr += 1) {
        _ = line;
        if (line_nr > 0) {
            try stdout.print("Line {d}: Active Buf: {d} Process line {d}:\n", .{ line_nr, active, (active + 2) % 3 });
            try partNrSearch([3][]u8{
                &buf[(active + 1) % 3],
                &buf[(active + 2) % 3],
                &buf[active],
            }, 140);
        }
        active = (active + 1) % 3;
    } else {
        const stop = (active + 1) % 3;
        while (active != stop) : (active = (active + 1) % 3) {
            for (0..buf[active].len) |j| {
                buf[active][j] = '.';
            }
        }
        try stdout.print("end window\n", .{});
        try partNrSearch([3][]u8{
            &buf[active],
            &buf[(active + 1) % 3],
            &buf[(active + 2) % 3],
        }, 140);
    }
}
