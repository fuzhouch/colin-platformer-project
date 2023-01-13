extends KinematicBody2D

var use_tsetseg = true
var current_sprite

var velocity = Vector2()
export var direction = -1 # Left

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
	current_sprite.playing = true
	
	if direction == 1:
		current_sprite.flip_h = not current_sprite.flip_h
	# $FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x

func _physics_process(delta):
	if is_on_wall():
		direction = direction * -1
		current_sprite.flip_h = not current_sprite.flip_h
	velocity.y += 20
	velocity.x = 50 * direction
	velocity = move_and_slide(velocity,Vector2.UP)
