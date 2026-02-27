extends AnimatableBody2D

@export var platformType = 1
@onready var Sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var Hitbox: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	match platformType:
		1: # solid
			Hitbox.rotation_degrees = 0
			Hitbox.one_way_collision = 0
			Sprite.play("1")
		2: # semisolid
			Hitbox.rotation_degrees = 0
			Hitbox.one_way_collision = 1
			Sprite.play("2")
		3: # vertical solid
			Hitbox.rotation_degrees = 90
			Hitbox.one_way_collision = 0
			Sprite.play("3")
		4: # vertical semisolid right
			Hitbox.rotation_degrees = 90
			Hitbox.one_way_collision = 1
			Sprite.play("4")
		5: # vertical semisolid left
			Hitbox.rotation_degrees = -90
			Hitbox.one_way_collision = 1
			Sprite.play("5")
