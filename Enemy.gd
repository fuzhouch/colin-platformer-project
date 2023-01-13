extends KinematicBody2D

var use_tsetseg = false
var current_sprite

var velocity = Vector2()
export var direction = -1 # Face left by default
export var detect_cliffs = true

func _ready():
	if use_tsetseg:
		current_sprite = $Tsetseg
		$Sprite.visible = false
		$Tsetseg.visible = true
		current_sprite.flip_h = true
	else:
		current_sprite = $Sprite
		$Sprite.visible = true
		$Tsetseg.visible = false
		current_sprite.flip_h = true
	current_sprite.playing = true
	
	if direction == 1:
		current_sprite.flip_h = not current_sprite.flip_h
	
	# Change Ray pointer in front of enemy sprite in a direction
	# it's moving to.
	# TODO: is it the best option? Apears RayCast2D is expensive.
	$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$FloorChecker.enabled = detect_cliffs

func _physics_process(delta):
	# We use "not $FloorChecker.is_colliding() because
	# the RayCast2D points to "floor" for detection, it
	# triggers turn-around only when floor and sprite are
	# "not" colliding
	if is_on_wall() or (detect_cliffs and is_on_floor() and not $FloorChecker.is_colliding()):
		direction = direction * -1
		current_sprite.flip_h = not current_sprite.flip_h
		$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	
	velocity.y += 20
	velocity.x = 50 * direction
	velocity = move_and_slide(velocity,Vector2.UP)
