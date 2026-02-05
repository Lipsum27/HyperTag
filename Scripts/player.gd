extends CharacterBody2D

#region onready
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var run_particles = $Run
@onready var slam_particles = $Slam
@onready var double_jump_particles = $DoubleJump
@onready var dash_particles = $Dash
@onready var slide_particles = $Slide
@onready var tag_particles = $Tag
@onready var cooldown = $Cooldown
#endregion

#region variables
@export var player_ID = 1

var speed:float
var speed_base = 200
var speed_bonus = 100
var scale_base = 2
var scale_bonus_plus = 2
var scale_bonus_minus = 0.75
var scale_target:Vector2
var gravity = 20
var jump_force = 500
var slam_force = 2000
var midair_jumps = 1
var midair_jumps_bonus = 1
var midair_jump_force = 400
var friction = 1.25
var max_y_speed = 10000
var max_x_speed = 10000
var walljump_x = 4
var walljump_y = 1.5
var dash_multiplier = 5
var slam_jump_multiplier = 1.5
var floor_speed_multiplier = 0.6
var wall_slide_speed_multiplier = 0.8
var slide_x = 5000
var double_jump_multiplier = 2
var full_coyote_time = 0.2
var full_slide_cooldown = .3
var full_slam_jump_time = 0.15
var slam_jump_draining:bool = false
var slam_jump_time = 0
var tagger_movement_variance = 1
var coyote_time = 0
var current_air_jumps = 1
var currently_slamming:bool = false
var slide_cooldown = 0
var midair_dash = 0
var instant_slide:bool
var round_end_buffer:int = 5
#endregion

func _ready(): # setup
	if player_ID > GlobalScript.player_count:
		queue_free()
	add_to_group("Players")
	position = GlobalScript.get("map_" + str(GlobalScript.Level) + "_player_spawns")[player_ID-1]
	scale_target = Vector2(scale_base, scale_base)

func spawn_particle(action: String):
	match action:
		"run":
			run_particles.direction.x = -20.0 * Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1]))
			if !run_particles.direction.x == 0:
				run_particles.emitting = true
		"double_jump":
			double_jump_particles.restart()
		"slam":
			slam_particles.restart()
			GlobalScript.shake_intensity = 10
			GlobalScript.shake_duration = .3
		"tag_player":
			tag_particles.restart()
			GlobalScript.shake_intensity = 15
			GlobalScript.shake_duration = .4
		"dash":
			if velocity.x > 0:
				dash_particles.position.x = 6.32
				dash_particles.texture = preload("res://Assets/Sprites/player_particles.png")
			elif velocity.x < 0:
				dash_particles.position.x = -6.32
				dash_particles.texture = preload("res://Assets/Sprites/player_particles_2.png")
			dash_particles.restart()
		"slide":
			if velocity.x > 0:
				slide_particles.position.x = 12
				slide_particles.texture = preload("res://Assets/Sprites/player_particles_3.png")
			elif velocity.x < 0:
				slide_particles.position.x = -12
				slide_particles.texture = preload("res://Assets/Sprites/player_particles_4.png")
			slide_particles.restart()

func _physics_process(_delta): # main loop
	
	# Speed up
	if player_ID == 1 && GlobalScript.p1PowerUp[1]> 0:
		speed = speed_base + speed_bonus
	elif player_ID == 2 && GlobalScript.p2PowerUp[1]> 0:
		speed = speed_base + speed_bonus
	elif player_ID == 3 && GlobalScript.p3PowerUp[1]> 0:
		speed = speed_base + speed_bonus
	elif player_ID == 4 && GlobalScript.p4PowerUp[1]> 0:
		speed = speed_base + speed_bonus
	else:
		speed = speed_base
	
	# Size power ups
	if player_ID == 1 && GlobalScript.p1PowerUp[2]> 0 && !GlobalScript.p1PowerUp[3]> 0:
		scale_target = Vector2(scale_base + scale_bonus_plus, scale_base + scale_bonus_plus)
	elif player_ID == 2 && GlobalScript.p2PowerUp[2]> 0 && !GlobalScript.p2PowerUp[3]> 0:
		scale_target = Vector2(scale_base + scale_bonus_plus, scale_base + scale_bonus_plus)
	elif player_ID == 3 && GlobalScript.p3PowerUp[2]> 0 && !GlobalScript.p3PowerUp[3]> 0:
		scale_target = Vector2(scale_base + scale_bonus_plus, scale_base + scale_bonus_plus)
	elif player_ID == 4 && GlobalScript.p4PowerUp[2]> 0 && !GlobalScript.p4PowerUp[3]> 0:
		scale_target = Vector2(scale_base + scale_bonus_plus, scale_base + scale_bonus_plus)
	elif player_ID == 1 && GlobalScript.p1PowerUp[3]> 0 && !GlobalScript.p1PowerUp[2]> 0:
		scale_target = Vector2(scale_base - scale_bonus_minus, scale_base - scale_bonus_minus)
	elif player_ID == 2 && GlobalScript.p2PowerUp[3]> 0 && !GlobalScript.p2PowerUp[2]> 0:
		scale_target = Vector2(scale_base - scale_bonus_minus, scale_base - scale_bonus_minus)
	elif player_ID == 3 && GlobalScript.p3PowerUp[3]> 0 && !GlobalScript.p3PowerUp[2]> 0:
		scale_target = Vector2(scale_base - scale_bonus_minus, scale_base - scale_bonus_minus)
	elif player_ID == 4 && GlobalScript.p4PowerUp[3]> 0 && !GlobalScript.p4PowerUp[2]> 0:
		scale_target = Vector2(scale_base - scale_bonus_minus, scale_base - scale_bonus_minus)
	else:
		scale_target = Vector2(scale_base, scale_base)
	
	scale = lerp(scale, scale_target, 0.1)
	
	if player_ID > GlobalScript.player_count:
		return
	
	#if GlobalScript.current_game_mode == 2 && GlobalScript.current_tagger == player_ID: # speed up from 0.5x speed to 1.5x speed
	if GlobalScript.current_tagger == player_ID and GlobalScript.seeker_speed_up: # speed up from 0.5x speed to 1.5x speed
		var tagger_timer_range = ( ( -1 * (1 + (GlobalScript.full_game_time - GlobalScript.timer) ) ) / GlobalScript.round_time ) + 0.58  # -0.5 to 0.5
		tagger_movement_variance = 1 + tagger_timer_range/2 #1 + tagger_timer_range
	else:
		tagger_movement_variance = 1
	
	run_particles.emitting = false
	
#region CoyoteTime 
	if is_on_floor():
		coyote_time = full_coyote_time
	else:
		coyote_time -= _delta
#endregion

#region MidairDash / WallJump / DoubleJump
	midair_dash -= _delta
	
	# reset jumps on slide
	if !is_on_floor():
		if !currently_slamming and  coyote_time < 0:
			if is_on_wall_only():
				if player_ID == 1 && GlobalScript.p1PowerUp[0]> 0:
					current_air_jumps = midair_jumps + midair_jumps_bonus
				elif player_ID == 2 && GlobalScript.p2PowerUp[0]> 0:
					current_air_jumps = midair_jumps + midair_jumps_bonus
				elif player_ID == 3 && GlobalScript.p3PowerUp[0]> 0:
					current_air_jumps = midair_jumps + midair_jumps_bonus
				elif player_ID == 4 && GlobalScript.p4PowerUp[0]> 0:
					current_air_jumps = midair_jumps + midair_jumps_bonus
				else:
					current_air_jumps = midair_jumps
	
	# other stuff
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > max_y_speed:
			velocity.y = max_y_speed
		if !currently_slamming and Input.is_action_just_pressed("Jump_" + str(GlobalScript.player_inputs[player_ID-1])) && coyote_time < 0:
			if is_on_wall_only():
				velocity.y = -jump_force * walljump_y * tagger_movement_variance
				velocity.x = jump_force * walljump_x * tagger_movement_variance
				move_and_slide()
				if is_on_wall(): # check for other wall
					velocity.x = jump_force * (0 - walljump_x) * tagger_movement_variance
					move_and_slide()
			elif !current_air_jumps == 0:
				if !Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) == 0: # dash
					velocity.x *= dash_multiplier * tagger_movement_variance
					velocity.y = -midair_jump_force * tagger_movement_variance
					spawn_particle("dash")
				else: # double jump
					velocity.y = -midair_jump_force * double_jump_multiplier * tagger_movement_variance
					spawn_particle("double_jump")
				currently_slamming = false
				current_air_jumps = current_air_jumps - 1
				midair_dash = .3
#endregion
	
#region Jump / slam
	if coyote_time > 0:
		if player_ID == 1 && GlobalScript.p1PowerUp[0]> 0:
			current_air_jumps = midair_jumps + midair_jumps_bonus
		elif player_ID == 2 && GlobalScript.p2PowerUp[0]> 0:
			current_air_jumps = midair_jumps + midair_jumps_bonus
		elif player_ID == 3 && GlobalScript.p3PowerUp[0]> 0:
			current_air_jumps = midair_jumps + midair_jumps_bonus
		elif player_ID == 4 && GlobalScript.p4PowerUp[0]> 0:
			current_air_jumps = midair_jumps + midair_jumps_bonus
		else:
			current_air_jumps = midair_jumps
		if currently_slamming:
			spawn_particle("slam")
		if Input.is_action_pressed("Jump_" + str(GlobalScript.player_inputs[player_ID-1])):
			if slam_jump_time > 0:
				velocity.y = -jump_force * slam_jump_multiplier * tagger_movement_variance
				currently_slamming = false
				coyote_time = 0
			else:
				coyote_time = 0
				velocity.y = -jump_force * tagger_movement_variance
	
	if is_on_floor():
		currently_slamming = false
	
	if !is_on_floor() && Input.is_action_just_pressed("Down_" + str(GlobalScript.player_inputs[player_ID-1])) && !currently_slamming && coyote_time < 0:
		currently_slamming = true
		velocity.y = slam_force * tagger_movement_variance
		slam_jump_time = full_slam_jump_time
		slam_jump_draining = false
	
	if is_on_floor():
		slam_jump_draining = true
	
	if slam_jump_draining:
		slam_jump_time -= _delta
#endregion
	
#region Slide
	if coyote_time > 0:
		if instant_slide == true: #instant slide, only works if first tick on floor
			if Input.is_action_pressed("Down_" + str(GlobalScript.player_inputs[player_ID-1])):
				if !Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) == 0 && slide_cooldown < 0:
					velocity.x = tagger_movement_variance * Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) * slide_x
					slide_cooldown = full_slide_cooldown
					spawn_particle("slide")
		elif Input.is_action_just_pressed("Down_" + str(GlobalScript.player_inputs[player_ID-1])): #regular slide
			if !Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) == 0 && slide_cooldown < 0:
					velocity.x = tagger_movement_variance * Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) * slide_x
					slide_cooldown = full_slide_cooldown
					spawn_particle("slide")
	
	slide_cooldown -= _delta
	
	if is_on_floor():
		instant_slide = false
	else:
		instant_slide = true
	#endregion
	
#region HorizontalMovement
	if is_on_floor():
		var horizontal_direction = (Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1]))) * floor_speed_multiplier
		velocity.x = ((velocity.x + (speed * tagger_movement_variance * horizontal_direction)) / friction)
	else:
		var horizontal_direction = (Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])))
		velocity.x = ((velocity.x + (speed * tagger_movement_variance * horizontal_direction)) / friction)
	if is_on_wall_only() && velocity.y > 0 && !currently_slamming:
		velocity.y = velocity.y * wall_slide_speed_multiplier
	if abs(velocity.x) > max_x_speed:
		velocity.x = (velocity.x / abs(velocity.x)) * max_x_speed
#endregion
	
#region Animations
	
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.offset.x = abs(animated_sprite_2d.offset.x)
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.offset.x = 0 - abs(animated_sprite_2d.offset.x)
	if is_on_wall_only() && !currently_slamming:
		animated_sprite_2d.play("Wallslide")
	elif midair_dash > 0 and !Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) == 0:
		animated_sprite_2d.play("DashAir")
	elif slide_cooldown > 0 && is_on_floor():
		animated_sprite_2d.play("DashGround")
	elif currently_slamming:
		animated_sprite_2d.play("Slam")
	elif is_on_floor():
		if !Input.get_axis("Left_" + str(GlobalScript.player_inputs[player_ID-1]),"Right_" + str(GlobalScript.player_inputs[player_ID-1])) == 0:
			animated_sprite_2d.play("Run")
			spawn_particle("run")
		else:
			animated_sprite_2d.play("Idle")
	else:
		if velocity.y < 0:
			animated_sprite_2d.play("Rise")
		else:
			animated_sprite_2d.play("Fall")
#endregion
	
#region Broadcast
	GlobalScript.player_pos[player_ID - 1] = position
	GlobalScript.player_vel[player_ID - 1] = velocity
#endregion
	
#region Colours
	if player_ID == 1:
		modulate = Color.from_hsv(0.0, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.current_tagger:
			modulate = Color.from_hsv(0.0, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 2:
		modulate = Color.from_hsv(0.169, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.current_tagger:
			modulate = Color.from_hsv(0.169, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 3:
		modulate = Color.from_hsv(0.326, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.current_tagger:
			modulate = Color.from_hsv(0.326, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 4:
		modulate = Color.from_hsv(0.589, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.current_tagger:
			modulate = Color.from_hsv(0.589, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
#endregion
	
	cooldown.visible = GlobalScript.last_tag_time + GlobalScript.tag_cooldown > GlobalScript.timer and player_ID == GlobalScript.current_tagger
	var time_remaining = int(round((GlobalScript.last_tag_time + GlobalScript.tag_cooldown) - GlobalScript.timer))
	cooldown.set_text(str(time_remaining+1))
	
	move_and_slide()

func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		var other_player = body # Check other player id
		var other_player_id = other_player.player_ID
		if player_ID == GlobalScript.current_tagger: #tagger / not
			await get_tree().create_timer(0.05).timeout #wait to prevent tag-back
			if GlobalScript.last_tag_time + GlobalScript.tag_cooldown < GlobalScript.timer and other_player.is_in_group("Players") and other_player.player_ID != player_ID: #Ignore collisions from own CollisionShape2D and ensure cooldown ended
				GlobalScript.current_tagger = other_player_id #Tag other player
				other_player.spawn_particle("tag_player")
				GlobalScript.last_tag_time = GlobalScript.timer
				if ( GlobalScript.full_game_time - GlobalScript.timer ) < round_end_buffer: # round end buffer (always give tagger a chance)
					GlobalScript.timer = GlobalScript.full_game_time - round_end_buffer
					GlobalScript.last_tag_time = GlobalScript.timer
				if GlobalScript.current_game_mode == 2: # Hot Potato timer reset
					GlobalScript.timer = 0
					GlobalScript.last_tag_time = GlobalScript.timer
					GlobalScript.full_game_time = GlobalScript.round_time
				# More tag effects here or smth
