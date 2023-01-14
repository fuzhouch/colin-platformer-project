extends KinematicBody2D

var current_sprite
var speed = 50

var velocity = Vector2()
export var direction = -1 # Face left by default
export var detect_cliffs = true
export var use_tsetseg = false

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
	# This is a required step to avoid tilemap
	# and HitCheck collises and trigger
	# _on_HitChecker_body_entered
	# $HitChecker.monitorable = false
	
	if direction == 1:
		current_sprite.flip_h = not current_sprite.flip_h
	
	# Change Ray pointer in front of enemy sprite in a direction
	# it's moving to.
	# TODO: is it the best option? Apears RayCast2D is expensive.
	$FloorChecker.position.x = $CollisionShape2D.shape.get_extents().x * direction
	$FloorChecker.enabled = detect_cliffs
	if not detect_cliffs:
		set_modulate(Color(1,0.5,1))

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
	velocity.x = speed * direction
	velocity = move_and_slide(velocity,Vector2.UP)


func _on_TopChecker_body_entered(body):
	current_sprite.play("squash")
	speed = 0
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(0, false)
	$TopChecker.set_collision_layer_bit(4, false)
	$TopChecker.set_collision_mask_bit(0, false)
	$HitChecker.set_collision_layer_bit(4, false)
	$HitChecker.set_collision_mask_bit(0, false)
	$DieTimer.start()
	body.bounce()

# Called automatically when Enemy detects a hit
# from other sprites. This should be only player.
# However there's a bug here, that hit checker may
# collise with tilemap. It also triggers this callback. 
func _on_HitChecker_body_entered(body):
	body.hit(position.x)


func _on_DieTimer_timeout():
	queue_free()
