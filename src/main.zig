const std = @import("std");
const assert = @import("std").debug.assert;
const rl = @import("raylib");
const rg = @import("raygui");

fn draw_shape(points: []const rl.Vector2, color: rl.Color) void {
    assert(points.len > 1);
    for (0..points.len) |i| {
        const current = points[i];
        const next = points[(i + 1) % points.len];
        rl.drawLineEx(current, next, 4.0, color);
    }
}

const Simplex = struct {
    A: rl.Vector2,
    B: ?rl.Vector2 = null,
    C: ?rl.Vector2 = null,
    points: usize,

    pub fn init(first_point: rl.Vector2) @This() {
        return .{
            .A = first_point,
            .points = 1,
        };
    }

    pub fn add_point(self: *@This(), next_point: rl.Vector2) void {
        if (self.B == null) {
            self.B = next_point;
            self.points = 2;
        } else if (self.C == null) {
            self.C = next_point;
            self.points = 3;
        }
    }

    pub fn remove_B(self: *@This()) void {
        self.B = self.C;
        self.C = null;
        self.points = 2;
    }

    pub fn remove_C(self: *@This()) void {
        self.C = null;
        self.points = 2;
    }
};

fn get_center(points: []const rl.Vector2) rl.Vector2 {
    assert(points.len > 0);
    var sum_x: f32 = 0;
    var sum_y: f32 = 0;
    for (points) |point| {
        sum_x += point.x;
        sum_y += point.y;
    }
    return .{ .x = sum_x / @as(f32, @floatFromInt(points.len)), .y = sum_y / @as(f32, @floatFromInt(points.len)) };
}

fn shape_collision(shape_1: []const rl.Vector2, shape_2: []const rl.Vector2) !bool {
    const center_1 = get_center(shape_1);
    const center_2 = get_center(shape_2);

    const dir = center_1.subtract(center_2).normalize();
    const first_point = support(shape_1, shape_2, dir);
    var simplex: Simplex = .init(first_point);
    var next_dir = first_point.negate();
    while (true) {
        const next_point = support(shape_1, shape_2, next_dir);
        if (next_point.dotProduct(next_dir) < 0) {
            return false;
        }
        simplex.add_point(next_point);
        if (handle_simplex(&simplex, &next_dir)) {
            return true;
        }
    }

    return false;
}

fn handle_simplex(simplex: *Simplex, dir: *rl.Vector2) bool {
    if (simplex.points == 2) {
        return line_case(simplex, dir);
    }
    return triangle_case(simplex, dir);
}

fn triple_product(A: rl.Vector2, B: rl.Vector2, C: rl.Vector2) rl.Vector2 {
    const A3 = rl.Vector3.init(A.x, A.y, 0.0);
    const B3 = rl.Vector3.init(B.x, B.y, 0.0);
    const C3 = rl.Vector3.init(C.x, C.y, 0.0);
    const result = A3.crossProduct(B3).crossProduct(C3);
    return rl.Vector2.init(result.x, result.y);
}

fn line_case(simplex: *Simplex, dir: *rl.Vector2) bool {
    assert(simplex.points == 2);
    const A = simplex.A;
    const B = simplex.B orelse unreachable;
    const AB = B.subtract(A);
    const AO = A.negate();
    const AB_perp = triple_product(AB, AO, AB);
    dir.* = AB_perp;
    return false;
}

fn triangle_case(simplex: *Simplex, dir: *rl.Vector2) bool {
    assert(simplex.points == 3);
    const A = simplex.A;
    const B = simplex.B orelse unreachable;
    const C = simplex.C orelse unreachable;
    const AB = B.subtract(A);
    const AC = C.subtract(A);
    const AO = A.negate();
    const AB_perp = triple_product(AC, AB, AB);
    const AC_perp = triple_product(AB, AC, AC);
    if (AB_perp.dotProduct(AO) > 0) {
        simplex.remove_C();
        dir.* = AB_perp;
        return false;
    }
    if (AC_perp.dotProduct(AO) > 0) {
        simplex.remove_B();
        dir.* = AC_perp;
        return false;
    }
    return true;
}

fn support(shape_1: []const rl.Vector2, shape_2: []const rl.Vector2, dir: rl.Vector2) rl.Vector2 {
    return furthest_point(shape_1, dir).subtract(furthest_point(shape_2, dir.negate()));
}

fn furthest_point(shape: []const rl.Vector2, direction: rl.Vector2) rl.Vector2 {
    var min_point: rl.Vector2 = undefined;
    var min = std.math.inf(f32);
    for (shape) |point| {
        const new_min = point.dotProduct(direction);
        if (new_min < min) {
            min = new_min;
            min_point = point;
        }
    }
    return min_point;
}

pub fn main() anyerror!void {
    var debug_allocator = std.heap.DebugAllocator(.{}).init;
    const allocator = debug_allocator.allocator();
    _ = allocator;

    // Initialization
    //--------------------------------------------------------------------------------------
    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "raylib-zig [core] example - basic window");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var show_message_box = false;

    const shape_1 = [_]rl.Vector2{
        rl.Vector2{ .x = 100.0, .y = 100.0 },
        rl.Vector2{ .x = 200.0, .y = 110.0 },
        rl.Vector2{ .x = 220.0, .y = 200.0 },
        rl.Vector2{ .x = 100.0, .y = 250.0 },
        rl.Vector2{ .x = 70.0, .y = 160.0 },
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        // Update
        //----------------------------------------------------------------------------------
        // TODO: Update your variables here
        //----------------------------------------------------------------------------------

        // Draw
        //----------------------------------------------------------------------------------
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.white);

        rl.drawText("Congrats! You created your first window!", 190, 200, 20, .light_gray);
        //----------------------------------------------------------------------------------

        const mouse_pos = rl.getMousePosition();
        const shape_following_mouse = blk: {
            const center = get_center(&shape_1);
            var result: [shape_1.len]rl.Vector2 = undefined;
            for (shape_1, 0..) |vec, i| {
                result[i] = rl.Vector2{
                    .x = vec.x + mouse_pos.x - center.x,
                    .y = vec.y + mouse_pos.y - center.y,
                };
            }
            break :blk result;
        };

        draw_shape(&shape_1, .light_gray);
        draw_shape(&shape_following_mouse, .red);

        const do_shapes_collide = try shape_collision(&shape_1, &shape_following_mouse);
        if (do_shapes_collide) {
            rl.drawText("O - collision", 350, 400, 20, .green);
        } else {
            rl.drawText("X - No collision", 330, 400, 20, .red);
        }

        if (rg.button(.init(24, 24, 120, 30), "#191#Show Message"))
            show_message_box = true;

        if (show_message_box) {
            const result = rg.messageBox(
                .init(85, 70, 250, 100),
                "#191#Message Box",
                "Hi! This is a message",
                "Nice;Cool",
            );

            if (result >= 0) show_message_box = false;
        }
    }
}
