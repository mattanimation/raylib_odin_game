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
	LOOSE,
	WIN,
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
	// enable sound
	rl.InitAudioDevice();

	music: rl.Music = rl.LoadMusicStream("resources/time_for_adventure.mp3");
	if rl.IsMusicValid(music) {
		music.looping = true;
	}
	game_over_music: rl.Music = rl.LoadMusicStream("resources/game_over.ogg");
	if rl.IsMusicValid(game_over_music) {
		game_over_music.looping = false;
	}

	jump_sound_ogg:rl.Sound = rl.LoadSound("resources/jump.ogg"); // Load OGG audio file
	hurt_sound_wav:rl.Sound = rl.LoadSound("resources/hurt.wav"); // Load WAV audio file
    

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
	hp: u8 = 3
	//blink_color: u8 = 0

//---------INIIT
	game_time = 15
	hp = 3
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
					rl.PlayMusicStream(music)
					currentScreen = .GAMEPLAY
				}
			}
		case .GAMEPLAY:
			{
				// play music
				rl.UpdateMusicStream(music);

				// TODO: Update GAMEPLAY screen variables here!
				//countdown_time = rl.GetTime() + game_time
				time_left = i16(game_end_time - rl.GetTime())
				//fmt.printf("%f, %f - %f\n", game_end_time, rl.GetTime(), time_left)
				// Press enter to change to ENDING screen
				if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
					currentScreen = .ENDING
				}
				if (time_left <= 0) {
					currentScreen = .WIN
				}
			}
		case .WIN: {
			if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
				currentScreen = .ENDING
			}
		}
		case .LOOSE: {
			rl.UpdateMusicStream(game_over_music);
			if (rl.IsKeyPressed(.ENTER) || rl.IsGestureDetected(rl.Gesture.TAP)) {
				currentScreen = .ENDING
			}
		}
		case .ENDING:
			{
				// TODO: Update ENDING screen variables here!
				
				// TODO: make this a proc and update proper context
				// --- REINIT -------------------------------------------------------------------
				game_time = 15
				hp = 3
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

					rl.PlaySound(jump_sound_ogg)
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
				min := 25
				for i := 0; i < len(falling_items_pool); i+=1 {
					if(rl.GetTime() > falling_items_times_pool[i]){
						falling_items_pool[i].y += 1000 * rl.GetFrameTime()
						if falling_items_pool[i].y >= f32(screenHeight + 64) {
							falling_items_pool[i].y = -64
							falling_items_pool[i].x = f32(rand.int_max(int(screenWidth) - (min * 2)) + min)
							falling_items_times_pool[i] = rl.GetTime() + f64(rand.int_max(5) + 1)
						}
						falling_items_rect_pool[i].x = falling_items_pool[i].x
						falling_items_rect_pool[i].y = falling_items_pool[i].y

						//CHECK FOR COLLISION WITH PLAYER
						if rl.CheckCollisionRecs(player_rect, falling_items_rect_pool[i]) {

							// reset that item
							falling_items_pool[i].y = -64							
							falling_items_pool[i].x = f32(rand.int_max(int(screenWidth) - (min * 2)) + min)
							falling_items_times_pool[i] = rl.GetTime() + f64(rand.int_max(5) + 1)

							// HIT!
							rl.PlaySound(hurt_sound_wav)
							hp -= 1
							if(hp <= 0){
								// DED
								rl.StopMusicStream(music)
								rl.PlayMusicStream(game_over_music)
								currentScreen = .LOOSE
							}
						}
					}
				}


				// draw items
				// blink_color = u8(100 + (math.sin(rl.GetTime() * 100) * 100))
				// { blink_color, blink_color, blink_color, 255}
				color_angle := f32(120 + (math.sin(rl.GetTime() * 10) * 120))
				for fi in falling_items_pool {
					rl.DrawRectangleV(fi, {64, 64}, rl.ColorFromHSV(color_angle, 1, 1))	
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
				rl.DrawText(fmt.caprintf("HP: %i", hp), 10, 10, 40, rl.WHITE)

			}
		case .WIN: {
			rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.PURPLE)
			rl.DrawText("YOU WIN!", 20, 20, 40, rl.DARKPURPLE)
			rl.DrawText(
				"PRESS ENTER",
				120,
				220,
				20,
				rl.DARKPURPLE,
			)

		}
		case .LOOSE: {
			rl.DrawRectangle(0, 0, screenWidth, screenHeight, rl.RED)
			rl.DrawText("YOU LOOSE", 20, 20, 40, rl.MAROON)
			rl.DrawText(
				"PRESS ENTER",
				120,
				220,
				20,
				rl.MAROON,
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

	//unload audio and close audio device access
	rl.UnloadSound(jump_sound_ogg)
	rl.UnloadSound(hurt_sound_wav)
	rl.StopMusicStream(music)
	rl.StopMusicStream(game_over_music)
	rl.UnloadMusicStream(music)
	rl.UnloadMusicStream(game_over_music)
	rl.CloseAudioDevice()

	rl.CloseWindow()
}
