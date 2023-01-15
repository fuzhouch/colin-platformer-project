extends KinematicBody2D

var in_double_jump = false
var velocity = Vector2(0, 0)
var coin = 0
var hit_points = 2

export var use_tsetseg = false
var current_sprite

# The constants here needs to be tuned, computing
# with size of screen and floors.
const SPEED = 180
const GRAVITY = 10
const JUMPFORCE = -500
const DOUBLE_JUMP_FORCE = -300

func _ready():
    if use_tsetseg:
        current_sprite = $Tsetseg
        $Sprite.visible = false
        $Tsetseg.visible = true
        $Mom.visible = false
    else:
        current_sprite = $Sprite
        $Sprite.visible = true
        $Tsetseg.visible = false
        $Mom.visible = false

func _physics_process(_delta):
    if Input.is_action_pressed("ui_right"):
        velocity.x = SPEED
        current_sprite.play("walk")
        current_sprite.flip_h = false
    elif Input.is_action_pressed("ui_left"):
        velocity.x = -SPEED
        current_sprite.play("walk")
        current_sprite.flip_h = true
    else:
        current_sprite.play("idle")

    # Make falling faster if no blocking.
    # When game running, velocity should be back to 0
    # when hitting floor
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
        current_sprite.play("jump")
    
    # "Slide" means - character keeps moving with same speed
    # when starts moving, it does not stop if we have no more
    # action.
    velocity = move_and_slide(velocity, Vector2.UP)
    
    velocity.x = lerp(velocity.x, 0, 0.1)
    # Lerp = Linear interpolation
    # 0.1 = 10%
    
    # If you wanna take action when coin
    # is collected, e.g., move to next level,
    # Colin says we may consider doing something here.
    # However I don't quite like this idea
    # as this function is called every frame.
    # Let's think about it for a better place.

func game_over():
    var scene = get_tree().current_scene.filename
    var _ignore = get_tree().change_scene(scene)

# This signal is triggered Steve enters this area (fall under cliff).
func _on_GameOverDetectArea2D_body_entered(_body):
    print("Game over!")
    game_over()

# This signal is triggerred when reaching end-game gate.
func _on_GameWinDetectArea2D_body_entered(_body):
    print("Game Win!")
    var scene = get_tree().current_scene.filename
    if scene == "res://Level1.tscn":
        var _ignore = get_tree().change_scene("res://Level2.tscn")
    else:
        var _ignore = get_tree().change_scene("res://Level1.tscn")
    return

# This function is called from Battery.gd
# in body_entered() signal. In fact GDScript
# allows calling body.coin from Battery.gd, but
# using method is better for clean interface.
func add_coin():
    coin = coin + 1
    hit_points = hit_points + 1
    print("coin collected: ", coin)
    print("coin refills hit point: ", hit_points)
    if coin == 2 and use_tsetseg:
        $Mom.visible = true
        $Tsetseg.visible = false
        current_sprite = $Mom
        print("Role change to mom!")

# Called by enemy sprite, hit_checker.body_entered() signal.
func hit(var enemy_x):
    hit_points = hit_points - 1
    print("hit_points: ", hit_points)
    if hit_points == 0:
        game_over()
    # This is required to avoid player keeps
    # pressing direction key to make Steve continue
    # moving forward and perform a successful attack
    # to enemy.
    Input.action_release("ui_left")
    Input.action_release("ui_right")
    # Temporarily change color a bit to display
    # a "hit" animation
    set_modulate(Color(1,0.3,0.3,0.5))
    # Jump back a bit
    velocity.y = JUMPFORCE * 0.3
    current_sprite.play("jump")
    $HitRecoverTimer.start()

    if position.x <= enemy_x:
        velocity.x = -800
    elif position.x > enemy_x:
        velocity.x = 800

# Called by enemy sprite when we have a successful hit.
func bounce():
    velocity.y = JUMPFORCE * 0.3
    current_sprite.play("jump")


func _on_HitRecoverTimer_timeout():
    set_modulate(Color(1,1,1,1))
