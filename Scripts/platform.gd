extends AnimatableBody2D

@export var PlatformType = 1
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	if PlatformType == 1:
		Type1()
	if PlatformType == 2:
		Type2()
	if PlatformType == 3:
		Type3()
	if PlatformType == 4:
		Type4()
	if PlatformType == 5:
		Type5()

func Type1():
	collision_shape_2d.rotation_degrees = 0
	collision_shape_2d.one_way_collision = 0
	animated_sprite_2d.play("1")

func Type2():
	collision_shape_2d.rotation_degrees = 0
	collision_shape_2d.one_way_collision = 1
	animated_sprite_2d.play("2")

func Type3():
	collision_shape_2d.rotation_degrees = 90
	collision_shape_2d.one_way_collision = 0
	animated_sprite_2d.play("3")

func Type4():
	collision_shape_2d.rotation_degrees = 90
	collision_shape_2d.one_way_collision = 1
	animated_sprite_2d.play("4")

func Type5():
	collision_shape_2d.rotation_degrees = -90
	collision_shape_2d.one_way_collision = 1
	animated_sprite_2d.play("5")
