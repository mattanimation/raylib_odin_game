package game

import "core:fmt"
import "core:strings"
import "core:math"
import "core:math/rand"
import rl "vendor:raylib"

GameScreen :: enum {
	LOGO = 0,
	TITLE,
	GAMEPLAY,
	ENDING,
	EXIT,
}

main :: proc() {

	c := context
	
	screenWidth: i32 = 1280
	screenHeight: i32 = 720
	exitWindowRequested := false   // Flag to request window to exit
    exitWindow := false            // Flag to set window to exit
	rl.InitWindow(screenWidth, screenHeight, "Simple Game")
	rl.SetTargetFPS(60)

	title_tex := rl.LoadTexture("resources/cat.png")

	player_vel: rl.Vector2
	player_pos: rl.Vector2
	player_grounded: bool
	player_flip: bool
	player_moving: bool
	player_run_texture := rl.LoadTexture("resources/scarfy.png")
	player_run_width := f32(player_run_texture.width)
	player_run_height := f32(player_run_texture.height)
	player_run_num_frames := 6
	player_wh: f32 = 128
	player_width := player_run_width / f32(player_run_num_frames)
	player_rect:rl.Rectangle

	player_run_frame_timer: f32
	player_run_current_frame: int
	player_run_frame_length := f32(0.1)

	startTime := rl.GetTime()
	currentScreen: GameScreen = .LOGO

	falling_items_pool: [10]rl.Vector2
	falling_items_rect_pool: [10]rl.Rectangle
	falling_items_times_pool: [10]f64

	game_end_time: f64
	game_time: f64 = 15
	time_left: i16

//---------INIIT
	player_pos = rl.Vector2{640, 320}
	player_rect = rl.Rectangle {player_pos.x, player_pos.y, player_width, player_wh}

	falling_items_pool = [10]rl.Vector2 {
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0},
		rl.Vector2{0,0}
	}
	
	falling_items_rect_pool = [10]rl.Rectangle {
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
		rl.Rectangle{0,0, 64, 64},
	}

	falling_items_times_pool = [10]f64 {
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
		rl.GetTime() + f64(rand.int_max(3)),
	}
	//------INIT

	for !exitWindow {

		if rl.WindowShouldClose() || rl.IsKeyPressed(.ESCAPE) { currentScreen = .EXIT }

		switch (currentScreen) {
		case .LOGO:
			{
				if (rl.GetTime() > startTime + 5) {
					currentScreen = .TITLE
				}
			}
		case .TITLE:
			{
				// TODO: Update TITLE screen variables here!

				// Press enter to change to GAMEPLAY screen
				if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
					game_end_time = rl.GetTime() + game_time
					currentScreen = .GAMEPLAY
				}
			}
		case .GAMEPLAY:
			{
				// TODO: Update GAMEPLAY screen variables here!
				//countdown_time = rl.GetTime() + game_time
				time_left = i16(game_end_time - rl.GetTime())
				//fmt.printf("%f, %f - %f\n", game_end_time, rl.GetTime(), time_left)
				// Press enter to change to ENDING screen
				if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
					currentScreen = .ENDING
				}
				if (time_left <= 0) {
					currentScreen = .ENDING
				}
			}
		case .ENDING:
			{
				// TODO: Update ENDING screen variables here!

				player_pos = rl.Vector2{640, 320}
				player_rect = rl.Rectangle {player_pos.x, player_pos.y, player_width, player_wh}

				falling_items_pool = [10]rl.Vector2 {
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0},
					rl.Vector2{0,0}
				}
				
				falling_items_rect_pool = [10]rl.Rectangle {
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
					rl.Rectangle{0,0, 64, 64},
				}

				falling_items_times_pool = [10]f64 {
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
					rl.GetTime() + f64(rand.int_max(3)),
				}

				// Press enter to return to TITLE screen
				if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
					currentScreen = .TITLE
				}
			}
		case .EXIT:
		    {
		    	if rl.IsKeyPressed(.Y) { exitWindow = true; }
                else if rl.IsKeyPressed(.N) { currentScreen = .TITLE }

		    }
		}

		// draw ------------------------------------------------------
		rl.BeginDrawing()
		rl.ClearBackground(rl.WHITE)
		switch (currentScreen) {
		case .LOGO:
			{
				rl.DrawText("LOGO PLACEHOLDER", 20, 20, 40, rl.LIGHTGRAY)
				rl.DrawText("Wait for 5 seconds...", 290, 220, 20, rl.GRAY)
			}
		case .TITLE:
			{
				// TODO: Update TITLE screen variables here!
				rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.GREEN)
				rl.DrawText("TITLE SCREEN", 20, 20, 40, rl.DARKGREEN)
				rl.DrawText(
					"PRESS ENTER or TAP to jump to GAMEPLAY SCREEN",
					120,
					220,
					20,
					rl.DARKGREEN,
				)
			}
		case .GAMEPLAY:
			{
				// TODO: Update GAMEPLAY screen variables here!
				rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.LIGHTGRAY)
				if rl.IsKeyDown(.LEFT) {
					player_vel.x = -400
					player_flip = true
					player_moving = true
				} else if rl.IsKeyDown(.RIGHT) {
					player_vel.x = 400
					player_flip = false
					player_moving = true
				} else {
					player_vel.x = 0
					player_moving = false
				}
				player_pos += player_vel * rl.GetFrameTime()

				player_vel.y += 2000 * rl.GetFrameTime()
				if player_grounded && rl.IsKeyPressed(.SPACE) {
					player_vel.y = -600
					player_grounded = false
				}
				// keep on the ground
				if player_pos.y > f32(rl.GetScreenHeight()) - player_wh {
					player_pos.y = f32(rl.GetScreenHeight()) - player_wh
					player_grounded = true
				}
				// keep in bounds
				if player_pos.x <= 0 {
					player_pos.x = 0
				}
				if player_pos.x >= f32(rl.GetScreenWidth()) - player_wh {
					player_pos.x = f32(rl.GetScreenWidth()) - player_wh
				}


				
				player_run_frame_timer += rl.GetFrameTime()
				if player_run_frame_timer > player_run_frame_length {
					player_run_current_frame += 1
					player_run_frame_timer = 0

					if player_run_current_frame == player_run_num_frames {
						player_run_current_frame = 0
					}
				}


				draw_player_source := rl.Rectangle {
					x      = player_moving ? f32(player_run_current_frame) * player_run_width / f32(player_run_num_frames) : 0,
					y      = 0,
					width  = player_width,
					height = player_run_height,
				}
				draw_player_dest := rl.Rectangle {
					x      = player_pos.x,
					y      = player_pos.y,
					width  = player_width,
					height = player_run_height,
				}

				if player_flip {
					draw_player_source.width = -draw_player_source.width
				}

				player_rect.x = player_pos.x
				player_rect.y = player_pos.y

				// update items
				for i := 0; i < len(falling_items_pool); i+=1 {
					if(rl.GetTime() > falling_items_times_pool[i]){
						falling_items_pool[i].y += 1000 * rl.GetFrameTime()
						if falling_items_pool[i].y >= f32(screenHeight + 64) {
							falling_items_pool[i].y = -64
							min := 25
							falling_items_pool[i].x = f32(rand.int_max(int(screenWidth) - (min * 2)) + min)
							falling_items_times_pool[i] = rl.GetTime() + f64(rand.int_max(5) + 1)
						}
						falling_items_rect_pool[i].x = falling_items_pool[i].x
						falling_items_rect_pool[i].y = falling_items_pool[i].y

						//CHECK FOR COLLISION WITH PLAYER
						if rl.CheckCollisionRecs(player_rect, falling_items_rect_pool[i]) {
							currentScreen = .ENDING
						}
					}
				}


				// draw items
				for fi in falling_items_pool {
					rl.DrawRectangleV(fi, {64, 64}, { 255, 0,0, 255})	
				}


				//rl.DrawRectangleV(player_pos, {64, 64}, rl.GREEN)
				//rl.DrawTextureV(player_run_texture, player_pos, rl.WHITE)
				//rl.DrawTextureEx(player_run_texture, player_pos, 0, 4, rl.WHITE)
				//rl.DrawTextureRec(player_run_texture, draw_player_source, player_pos, rl.WHITE)
				rl.DrawTexturePro(
					player_run_texture,
					draw_player_source,
					draw_player_dest,
					0,
					0,
					rl.WHITE,
				)

				titl := fmt.caprintf("Time Left: {}", time_left)
				rl.DrawText(titl, i32(f32(screenWidth) * 0.5), 10, 40, rl.WHITE)
				rl.DrawText(
					"Dodge the falling items! ",
					i32(f32(screenWidth) * 0.5),
					48,
					24,
					rl.WHITE,
				)

			}
		case .ENDING:
			{
				// TODO: Update ENDING screen variables here!
				rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.BLUE)
				rl.DrawText("ENDING SCREEN", 20, 20, 40, rl.DARKBLUE)
				rl.DrawText(
					"PRESS ENTER or TAP to RETURN to TITLE SCREEN",
					120,
					220,
					20,
					rl.DARKBLUE,
				)

			}
		case .EXIT:
			{
				rl.DrawRectangle(0, i32((f32(screenHeight) * 0.5) - 100), screenWidth, 200, rl.BLACK);
                rl.DrawText("Are you sure you want to exit program? [Y/N]", 40, i32((f32(screenHeight) * 0.5) - 60), 30, rl.WHITE);
			}
		}


		rl.EndDrawing()
	}

	rl.CloseWindow()
}
