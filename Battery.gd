extends Area2D

export var use_tsetseg = false
var current_sprite

# Called when the node enters the scene tree for the first time.
func _ready():
    if use_tsetseg:
        current_sprite = $Tsetseg
        $Sprite.visible = false
        $Tsetseg.visible = true
    else:
        current_sprite = $Sprite
        $Sprite.visible = true
        $Tsetseg.visible = false
    current_sprite.playing = true

func _on_Battery_body_entered(body):
    $AnimationPlayer.play("BatteryBounce")
    body.add_coin()


func _on_AnimationPlayer_animation_finished(anim_name):
    queue_free()
