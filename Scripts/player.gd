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
var speedBase = 200
var speedBonus = 100
var scaleBase = 2
var scaleBonusPlus = 2
var scaleBonusMinus = 0.75
var scaleTarget:Vector2
var gravity = 20
var jumpForce = 500
var slamForce = 2000
var midairJumps = 1
var midairJumps_bonus = 1
var midairJumpForce = 400
var friction = 1.25
var yMaxSpeed = 10000
var XMaxSpeed = 10000
var wallJumpX = 4
var wallJumpY = 1.5
var dashMultiplier = 5
var slamJumpMultiplier = 1.5
var floorSpeedMultiplier = 0.6
var wallSlideSpeedMultiplier = 0.8
var slideX = 5000
var doubleJumpMultiplier = 2
var fullCoyoteTime = 0.2
var fullSlideCooldown = .3
var fullSlamJumpTime = 0.15
var slamJumpDraining:bool = false
var slamJumpTime = 0
var taggerMovementVariance = 1
var coyoteTime = 0
var currentAirJumps = 1
var currentlySlamming:bool = false
var slideCooldown = 0
var midairDash = 0
var instantSlide:bool
var roundEndBuffer:int = 5
#endregion

func _ready(): # setup
	if player_ID > GlobalScript.playerCount:
		queue_free()
	add_to_group("Players")
	position = GlobalScript.get("map" + str(GlobalScript.level) + "PlayerSpawns")[player_ID-1]
	scaleTarget = Vector2(scaleBase, scaleBase)

func spawn_particle(action: String):
	match action:
		"run":
			run_particles.direction.x = -20.0 * Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1]))
			if !run_particles.direction.x == 0:
				run_particles.emitting = true
		"double_jump":
			double_jump_particles.restart()
		"slam":
			slam_particles.restart()
			GlobalScript.shakeIntensity = 10
			GlobalScript.shakeDuration = .3
		"tag_player":
			tag_particles.restart()
			GlobalScript.shakeIntensity = 15
			GlobalScript.shakeDuration = .4
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

func _physics_process(delta): # main loop
	
	# Speed up
	if player_ID == 1 && GlobalScript.p1PowerUp[1]> 0:
		speed = speedBase + speedBonus
	elif player_ID == 2 && GlobalScript.p2PowerUp[1]> 0:
		speed = speedBase + speedBonus
	elif player_ID == 3 && GlobalScript.p3PowerUp[1]> 0:
		speed = speedBase + speedBonus
	elif player_ID == 4 && GlobalScript.p4PowerUp[1]> 0:
		speed = speedBase + speedBonus
	else:
		speed = speedBase
	
	# Size power ups
	if player_ID == 1 && GlobalScript.p1PowerUp[2]> 0 && !GlobalScript.p1PowerUp[3]> 0:
		scaleTarget = Vector2(scaleBase + scaleBonusPlus, scaleBase + scaleBonusPlus)
	elif player_ID == 2 && GlobalScript.p2PowerUp[2]> 0 && !GlobalScript.p2PowerUp[3]> 0:
		scaleTarget = Vector2(scaleBase + scaleBonusPlus, scaleBase + scaleBonusPlus)
	elif player_ID == 3 && GlobalScript.p3PowerUp[2]> 0 && !GlobalScript.p3PowerUp[3]> 0:
		scaleTarget = Vector2(scaleBase + scaleBonusPlus, scaleBase + scaleBonusPlus)
	elif player_ID == 4 && GlobalScript.p4PowerUp[2]> 0 && !GlobalScript.p4PowerUp[3]> 0:
		scaleTarget = Vector2(scaleBase + scaleBonusPlus, scaleBase + scaleBonusPlus)
	elif player_ID == 1 && GlobalScript.p1PowerUp[3]> 0 && !GlobalScript.p1PowerUp[2]> 0:
		scaleTarget = Vector2(scaleBase - scaleBonusMinus, scaleBase - scaleBonusMinus)
	elif player_ID == 2 && GlobalScript.p2PowerUp[3]> 0 && !GlobalScript.p2PowerUp[2]> 0:
		scaleTarget = Vector2(scaleBase - scaleBonusMinus, scaleBase - scaleBonusMinus)
	elif player_ID == 3 && GlobalScript.p3PowerUp[3]> 0 && !GlobalScript.p3PowerUp[2]> 0:
		scaleTarget = Vector2(scaleBase - scaleBonusMinus, scaleBase - scaleBonusMinus)
	elif player_ID == 4 && GlobalScript.p4PowerUp[3]> 0 && !GlobalScript.p4PowerUp[2]> 0:
		scaleTarget = Vector2(scaleBase - scaleBonusMinus, scaleBase - scaleBonusMinus)
	else:
		scaleTarget = Vector2(scaleBase, scaleBase)
	
	scale = lerp(scale, scaleTarget, 0.1)
	
	if player_ID > GlobalScript.playerCount:
		return
	
	#if GlobalScript.currentGameMode == 2 && GlobalScript.currentTagger == player_ID: # speed up from 0.5x speed to 1.5x speed
	if GlobalScript.currentTagger == player_ID and GlobalScript.seekerSpeedUp: # speed up from 0.5x speed to 1.5x speed
		var taggerTimerRange = ( ( -1 * (1 + (GlobalScript.fullGameTime - GlobalScript.timer) ) ) / GlobalScript.roundTime ) + 0.58  # -0.5 to 0.5
		taggerMovementVariance = 1 + taggerTimerRange/2 #1 + taggerTimerRange
	else:
		taggerMovementVariance = 1
	
	run_particles.emitting = false
	
#region CoyoteTime 
	if is_on_floor():
		coyoteTime = fullCoyoteTime
	else:
		coyoteTime -= delta
#endregion

#region MidairDash / WallJump / DoubleJump
	midairDash -= delta
	
	# reset jumps on slide
	if !is_on_floor():
		if !currentlySlamming and  coyoteTime < 0:
			if is_on_wall_only():
				if player_ID == 1 && GlobalScript.p1PowerUp[0]> 0:
					currentAirJumps = midairJumps + midairJumps_bonus
				elif player_ID == 2 && GlobalScript.p2PowerUp[0]> 0:
					currentAirJumps = midairJumps + midairJumps_bonus
				elif player_ID == 3 && GlobalScript.p3PowerUp[0]> 0:
					currentAirJumps = midairJumps + midairJumps_bonus
				elif player_ID == 4 && GlobalScript.p4PowerUp[0]> 0:
					currentAirJumps = midairJumps + midairJumps_bonus
				else:
					currentAirJumps = midairJumps
	
	# other stuff
	if !is_on_floor():
		velocity.y += gravity
		if velocity.y > yMaxSpeed:
			velocity.y = yMaxSpeed
		if !currentlySlamming and Input.is_action_just_pressed("Jump_" + str(GlobalScript.playerInputs[player_ID-1])) && coyoteTime < 0:
			if is_on_wall_only():
				velocity.y = -jumpForce * wallJumpY * taggerMovementVariance
				velocity.x = jumpForce * wallJumpX * taggerMovementVariance
				move_and_slide()
				if is_on_wall(): # check for other wall
					velocity.x = jumpForce * (0 - wallJumpX) * taggerMovementVariance
					move_and_slide()
			elif !currentAirJumps == 0:
				if !Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) == 0: # dash
					velocity.x *= dashMultiplier * taggerMovementVariance
					velocity.y = -midairJumpForce * taggerMovementVariance
					spawn_particle("dash")
				else: # double jump
					velocity.y = -midairJumpForce * doubleJumpMultiplier * taggerMovementVariance
					spawn_particle("double_jump")
				currentlySlamming = false
				currentAirJumps = currentAirJumps - 1
				midairDash = .3
#endregion
	
#region Jump / slam
	if coyoteTime > 0:
		if player_ID == 1 && GlobalScript.p1PowerUp[0]> 0:
			currentAirJumps = midairJumps + midairJumps_bonus
		elif player_ID == 2 && GlobalScript.p2PowerUp[0]> 0:
			currentAirJumps = midairJumps + midairJumps_bonus
		elif player_ID == 3 && GlobalScript.p3PowerUp[0]> 0:
			currentAirJumps = midairJumps + midairJumps_bonus
		elif player_ID == 4 && GlobalScript.p4PowerUp[0]> 0:
			currentAirJumps = midairJumps + midairJumps_bonus
		else:
			currentAirJumps = midairJumps
		if currentlySlamming:
			spawn_particle("slam")
		if Input.is_action_pressed("Jump_" + str(GlobalScript.playerInputs[player_ID-1])):
			if slamJumpTime > 0:
				velocity.y = -jumpForce * slamJumpMultiplier * taggerMovementVariance
				currentlySlamming = false
				coyoteTime = 0
			else:
				coyoteTime = 0
				velocity.y = -jumpForce * taggerMovementVariance
	
	if is_on_floor():
		currentlySlamming = false
	
	if !is_on_floor() && Input.is_action_just_pressed("Down_" + str(GlobalScript.playerInputs[player_ID-1])) && !currentlySlamming && coyoteTime < 0:
		currentlySlamming = true
		velocity.y = slamForce * taggerMovementVariance
		slamJumpTime = fullSlamJumpTime
		slamJumpDraining = false
	
	if is_on_floor():
		slamJumpDraining = true
	
	if slamJumpDraining:
		slamJumpTime -= delta
#endregion
	
#region Slide
	if coyoteTime > 0:
		if instantSlide == true: #instant slide, only works if first tick on floor
			if Input.is_action_pressed("Down_" + str(GlobalScript.playerInputs[player_ID-1])):
				if !Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) == 0 && slideCooldown < 0:
					velocity.x = taggerMovementVariance * Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) * slideX
					slideCooldown = fullSlideCooldown
					spawn_particle("slide")
		elif Input.is_action_just_pressed("Down_" + str(GlobalScript.playerInputs[player_ID-1])): #regular slide
			if !Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) == 0 && slideCooldown < 0:
					velocity.x = taggerMovementVariance * Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) * slideX
					slideCooldown = fullSlideCooldown
					spawn_particle("slide")
	
	slideCooldown -= delta
	
	if is_on_floor():
		instantSlide = false
	else:
		instantSlide = true
	#endregion
	
#region HorizontalMovement
	if is_on_floor():
		var horizontalDirection = (Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1]))) * floorSpeedMultiplier
		velocity.x = ((velocity.x + (speed * taggerMovementVariance * horizontalDirection)) / friction)
	else:
		var horizontalDirection = (Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])))
		velocity.x = ((velocity.x + (speed * taggerMovementVariance * horizontalDirection)) / friction)
	if is_on_wall_only() && velocity.y > 0 && !currentlySlamming:
		velocity.y = velocity.y * wallSlideSpeedMultiplier
	if abs(velocity.x) > XMaxSpeed:
		velocity.x = (velocity.x / abs(velocity.x)) * XMaxSpeed
#endregion
	
#region Animations
	
	if velocity.x > 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.offset.x = abs(animated_sprite_2d.offset.x)
	elif velocity.x < 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.offset.x = 0 - abs(animated_sprite_2d.offset.x)
	if is_on_wall_only() && !currentlySlamming:
		animated_sprite_2d.play("Wallslide")
	elif midairDash > 0 and !Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) == 0:
		animated_sprite_2d.play("DashAir")
	elif slideCooldown > 0 && is_on_floor():
		animated_sprite_2d.play("DashGround")
	elif currentlySlamming:
		animated_sprite_2d.play("Slam")
	elif is_on_floor():
		if !Input.get_axis("Left_" + str(GlobalScript.playerInputs[player_ID-1]),"Right_" + str(GlobalScript.playerInputs[player_ID-1])) == 0:
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
	GlobalScript.playerPos[player_ID - 1] = position
	GlobalScript.playerVel[player_ID - 1] = velocity
#endregion
	
#region Colours
	if player_ID == 1:
		modulate = Color.from_hsv(0.0, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.currentTagger:
			modulate = Color.from_hsv(0.0, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 2:
		modulate = Color.from_hsv(0.169, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.currentTagger:
			modulate = Color.from_hsv(0.169, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 3:
		modulate = Color.from_hsv(0.326, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.currentTagger:
			modulate = Color.from_hsv(0.326, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
	if player_ID == 4:
		modulate = Color.from_hsv(0.589, 0.5, 1.0, 1.0)
		if player_ID == GlobalScript.currentTagger:
			modulate = Color.from_hsv(0.589, ((sin(GlobalScript.timer * 8) + 1) / 4), 1.0, 1.0)
#endregion
	
	cooldown.visible = GlobalScript.lastTagTime + GlobalScript.tagCooldown > GlobalScript.timer and player_ID == GlobalScript.currentTagger
	var timeRemaining = int(round((GlobalScript.lastTagTime + GlobalScript.tagCooldown) - GlobalScript.timer))
	cooldown.set_text(str(timeRemaining+1))
	
	move_and_slide()

func _on_player_collision_body_entered(body: Node2D) -> void:
	if body.is_in_group("Players"):
		var otherPlayer = body # Check other player id
		var otherPlayerId = otherPlayer.player_ID
		if player_ID == GlobalScript.currentTagger: #tagger / not
			await get_tree().create_timer(0.05).timeout #wait to prevent tag-back
			if GlobalScript.lastTagTime + GlobalScript.tagCooldown < GlobalScript.timer and otherPlayer.is_in_group("Players") and otherPlayer.player_ID != player_ID: #Ignore collisions from own CollisionShape2D and ensure cooldown ended
				GlobalScript.currentTagger = otherPlayerId #Tag other player
				otherPlayer.spawn_particle("tag_player")
				GlobalScript.lastTagTime = GlobalScript.timer
				if ( GlobalScript.fullGameTime - GlobalScript.timer ) < roundEndBuffer: # round end buffer (always give tagger a chance)
					GlobalScript.timer = GlobalScript.fullGameTime - roundEndBuffer
					GlobalScript.lastTagTime = GlobalScript.timer
				if GlobalScript.currentGameMode == 2: # Hot Potato timer reset
					GlobalScript.timer = 0
					GlobalScript.lastTagTime = GlobalScript.timer
					GlobalScript.fullGameTime = GlobalScript.roundTime
				# More tag effects here or smth
