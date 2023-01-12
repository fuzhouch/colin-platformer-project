extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Battery_body_entered(body):
	$AnimationPlayer.play("BatteryBounce")
	body.add_coin()


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
