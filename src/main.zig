const rl = @import("raylib");
const rg = @import("raygui");

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
