extends KinematicBody2D

var coins = 0
var velocity = Vector2(0, 0)

func _physics_process(delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = 100
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -100
	else:
		pass
	
	# "Slide" means - character keeps moving with same speed
	# when starts moving, it does not stop if we have no more
	# action.
	move_and_slide(velocity)
	
	velocity.x = lerp(velocity.x, 0, 0.1)
	# Lerp = Linear interoperation
	# 0.1 = 10%
