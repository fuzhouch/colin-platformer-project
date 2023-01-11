extends KinematicBody2D

var in_double_jump = false
var velocity = Vector2(0, 0)

# The constants here needs to be tuned, computing
# with size of screen and floors.
const SPEED = 180
const GRAVITY = 10
const JUMPFORCE = -500
const DOUBLE_JUMP_FORCE = -300

func _physics_process(_delta):
	if Input.is_action_pressed("ui_right"):
		velocity.x = SPEED
		$Sprite.play("walk")
		$Sprite.flip_h = false
	elif Input.is_action_pressed("ui_left"):
		velocity.x = -SPEED
		$Sprite.play("walk")
		$Sprite.flip_h = true
	else:
		$Sprite.play("idle")

	# Simply adding velocity is incorrect. It should
	# be reset to 0 on collision (Tsetseg falls on floor)
	velocity.y += GRAVITY
	
	# "Just" pressing means we process it only once at
	# the very moment that a key is pressed, not every
	# frame. It's important to use "just" pressing to
	# process actions like jumping. If we use
	# is_action_pressed() here,
	# sprite can simply fly when holding jump key, because
	# every frame with jump key pressed is treated as a new
	# jump action.
	#
	# Is_on_floor() needs a definition of direction of floor.
	# or it just does not work.
	
	# I added a small quiz to myself: How to implement dump jump?
	# Below is the code
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor():
			velocity.y = JUMPFORCE
			in_double_jump = false
		else:
			if not in_double_jump: # Already in double jump status
				velocity.y = DOUBLE_JUMP_FORCE
				in_double_jump = true
		
	# $Sprite.play() appears to be a declarative call, that
	# the last .play() calls decides the animation we finally
	# play in this frame.
	if not is_on_floor():
		$Sprite.play("jump")
	
	# "Slide" means - character keeps moving with same speed
	# when starts moving, it does not stop if we have no more
	# action.
	velocity = move_and_slide(velocity, Vector2.UP)
	
	velocity.x = lerp(velocity.x, 0, 0.1)
	# Lerp = Linear interpolation
	# 0.1 = 10%

# This signal is triggered Steve enters this area (fall under cliff).
func _on_GameOverDetectArea2D_body_entered(body):
	print("Game over!")
	get_tree().change_scene("res://Level1.tscn")

# This signal is triggerred when reaching end-game gate.
func _on_GameWinDetectArea2D_body_entered(body):
	print("Game Win!") 
	get_tree().change_scene("res://Level1.tscn")
