const std = @import("std");

fn isSymbol(c: u8) bool {
    if (c != '.' and c != '\n' and (c < '0' or c > '9')) {
        return true;
    }
    return false;
}

test "isSymbol validation" {
    try std.testing.expect(isSymbol('*') == true);
}

test "isSymbol fails" {
    try std.testing.expect(isSymbol('0') == false);
    try std.testing.expect(isSymbol('5') == false);
    try std.testing.expect(isSymbol('9') == false);
    try std.testing.expect(isSymbol('.') == false);
}

fn hasAdjacentSymbol(window: [3][]u8, startIdx: usize, idx: usize) bool {
    const top = window[0];
    const activeRow = window[1];
    const bottom = window[2];
    if (startIdx > 0) {
        // check left of number
        if (activeRow[startIdx - 1] != '.') {
            return true;
        }

        // check diagonals on left side
        if (isSymbol(top[startIdx - 1])) {
            return true;
        }
        if (isSymbol(bottom[startIdx - 1])) {
            return true;
        }
    }

    // check above and below number and right side diagonals
    for (0..(idx - startIdx + 1)) |i| {
        if (isSymbol(top[startIdx + i])) {
            return true;
        }
        if (isSymbol(bottom[startIdx + i])) {
            return true;
        }
    }

    return false;
}

fn partNrSearch(window: [3][]u8) !u64 {
    var partsFound: u64 = 0;

    const activeRow = window[1];

    var nrFound = false;
    var start: usize = undefined;
    row: for (activeRow, 0..) |c, i| {
        nrFound = switch (c) {
            '0'...'9' => nr: {
                if (!nrFound) {
                    start = i;
                }
                break :nr true;
            },
            '.' => empty: {
                if (nrFound) {
                    if (hasAdjacentSymbol(window, start, i)) {
                        partsFound += try std.fmt.parseInt(u64, activeRow[start..i], 10);
                    }
                }
                break :empty false;
            },
            '\n' => {
                if (nrFound) {
                    if (hasAdjacentSymbol(window, start, i)) {
                        partsFound += try std.fmt.parseInt(u64, activeRow[start..i], 10);
                    }
                }
                break :row;
            },
            else => part: {
                if (nrFound) {
                    partsFound += try std.fmt.parseInt(u64, activeRow[start..i], 10);
                }
                break :part false;
            },
        };
    }
    return partsFound;
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    const file = try std.fs.cwd().openFile("input.txt", .{});
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
    var total: u64 = 0;

    // for this problem we are going to abuse the fact that all lines are same length
    while (try in_stream.readUntilDelimiterOrEof(&buf[active], '\n')) |line| : //
    (line_nr += 1) {
        _ = line;
        if (line_nr > 0) {
            total += try partNrSearch([3][]u8{
                &buf[(active + 1) % 3],
                &buf[(active + 2) % 3],
                &buf[active],
            });
        }
        active = (active + 1) % 3;
    } else {
        const stop = (active + 1) % 3;
        // TODO: may not need that many here
        while (active != stop) : (active = (active + 1) % 3) {
            for (0..buf[active].len) |j| {
                buf[active][j] = '.';
            }
        }
        //try stdout.print("end window\n", .{});
        total += try partNrSearch([3][]u8{
            &buf[active],
            &buf[(active + 1) % 3],
            &buf[(active + 2) % 3],
        });
    }
    try stdout.print("total: {d}\n", .{total});
}
