const std = @import("std");
const ascii = std.ascii;
const debug = std.debug;

//// day01A solution
//fn findCoordinate(line: []u8) !u32 {
//    var v: [2]u8 = undefined;
//    v[0] = for (line) |c| {
//        if (ascii.isDigit(c)) {
//            break c;
//        }
//    } else unreachable;
//
//    var i: usize = line.len - 1;
//    v[1] = while (i >= 0) : (i -= 1) {
//        if (ascii.isDigit(line[i])) {
//            break line[i];
//        }
//    };
//    return std.fmt.parseInt(u32, &v, 10);
//}

const Digit = enum(u8) {
    one = 49,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,
};

fn getDigitFromName(n: []const u8) ?u8 {
    //const testName: std.builtin.EnumField = .{ .name = n, .value = 1 };
    const fields = @typeInfo(Digit).Enum.fields;

    //std.debug.print("{}\n", .{@TypeOf(fields[0].name)});
    //const info = @typeInfo(Digit);
    //inline for (info.Enum.fields) |field| {
    //    std.debug.print("{s}\n", .{field.name});
    //}

    //switch (n) {
    //    inline fields[0].name...fields[fields.len - 1].name => |case| {
    //        return case;
    //    },
    //    //inline else => |case| std.debug.print("{}\n", .{case}),
    //}

    inline for (fields) |field| {
        //std.debug.print("digit - {s} {s}\n", .{ field.name, n });
        if (std.mem.eql(u8, field.name, n)) {
            return field.value;
        }
    }

    return null;
}

// day01B solution
fn findCoordinate(line: []u8) !u32 {
    var v: [2]u8 = undefined;

    var i: u64 = 0;
    v[0] = first: while (i < line.len) : (i += 1) {
        digit_check: for (0..5) |c| {
            if (c == 0) {
                if (ascii.isDigit(line[i])) {
                    break :first line[i];
                }
                continue :digit_check;
            }
            if (i + c < line.len) {
                if (getDigitFromName(line[i .. i + c + 1])) |d| {
                    break :first d;
                }
            }
        }
    } else unreachable;

    var j: u64 = line.len - 1;
    v[1] = second: while (j >= 0) : (j -= 1) {
        reverse_check: for (0..5) |c| {
            if (c == 0) {
                if (ascii.isDigit(line[j])) {
                    break :second line[j];
                }
                continue :reverse_check;
            }
            if ((c < j) and ((j - c) >= 0)) {
                const start: u64 = j - c;
                //std.debug.print("{d}\n", .{start});
                if (getDigitFromName(line[start .. j + 1])) |d| {
                    break :second d;
                }
            }
        }
    } else unreachable;
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
