extends KinematicBody2D

var allow_double_jump = true
var velocity = Vector2(0, 0)
var coin = 0
var hit_points = 2

export var use_tsetseg = false
var current_sprite

# The constants here needs to be tuned, computing
# with size of screen and floors.
const SPEED = 180
const GRAVITY = 40
const JUMPFORCE = -1000
const DOUBLE_JUMP_FORCE = -700
const HIT_MOVEBACK = 500
const MAX_FALL_SPEED = 2000

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

func _set_move():
    if Input.is_action_pressed("ui_right"):
        current_sprite.play("walk")
        current_sprite.flip_h = false
        velocity.x = SPEED
    elif Input.is_action_pressed("ui_left"):
        current_sprite.play("walk")
        current_sprite.flip_h = true
        velocity.x = -SPEED
    else:
        current_sprite.play("idle")
    # A possible bug is we set direction to
    # 1 (left), -1 (right) and 0 (idle), then
    # we set velocity.x = direction * SPEED.
    # This can cause bug when hit() also
    # change velocity.x due to enemy push back.
    #
    # Learning is, if we mean to "idle", then
    # really don't change its value.

func _set_jump():
    var fall_adjustment = 1
    var jump_falling = false
    var on_floor = is_on_floor()
    if on_floor:
        # Reset to basic status
        allow_double_jump = true
    else:
        current_sprite.play("jump")
        if velocity.y == 0:
            jump_falling = true

    if Input.is_action_just_pressed("ui_up"):
        if on_floor:
            velocity.y = JUMPFORCE
        elif allow_double_jump:
            allow_double_jump = false
            velocity.y = DOUBLE_JUMP_FORCE

    if jump_falling:
        fall_adjustment = 1.2

    if velocity.y < MAX_FALL_SPEED:
        velocity.y += GRAVITY * fall_adjustment
    else:
        velocity.y = MAX_FALL_SPEED

func _physics_process(_delta):
    _set_move()
    _set_jump()
    velocity = move_and_slide(velocity, Vector2.UP)
    velocity.x = lerp(velocity.x, 0, 0.1)

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
    # Enemy push back: Jump back a bit
    velocity.y = JUMPFORCE * 0.3
    current_sprite.play("jump")
    $HitRecoverTimer.start() # Color back to normal

    if position.x <= enemy_x:
        velocity.x -= HIT_MOVEBACK
    elif position.x > enemy_x:
        velocity.x += HIT_MOVEBACK

# Called by enemy sprite when we have a successful hit.
func bounce():
    velocity.y = JUMPFORCE * 0.3
    current_sprite.play("jump")


func _on_HitRecoverTimer_timeout():
    set_modulate(Color(1,1,1,1))
