const assert = @import("std").debug.assert;
const rl = @import("raylib");
const rg = @import("raygui");

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

fn draw_shape(points: []const rl.Vector2, color: rl.Color) void {
    assert(points.len > 1);
    for (0..points.len) |i| {
        const current = points[i];
        const next = points[(i + 1) % points.len];
        rl.drawLineEx(current, next, 4.0, color);
    }
}

fn shape_collision(shape_1: []const rl.Vector2, shape_2: []const rl.Vector2) bool {
    const center_1 = get_center(shape_1);
    const center_2 = get_center(shape_2);

    return @abs(center_1.x - center_2.x) < 100;
}

pub fn main() anyerror!void {
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

        const do_shapes_collide = shape_collision(&shape_1, &shape_following_mouse);
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
