extends Node2D

export var always_on_screen = false

# Called when the node enters the scene tree for the first time.
func _ready():
    if always_on_screen:
        $TouchScreenUp.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
        $TouchScreenDown.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
        $TouchScreenLeft.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
        $TouchScreenRight.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
        $TouchScreenJump.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
    else:
        $TouchScreenUp.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
        $TouchScreenDown.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
        $TouchScreenLeft.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
        $TouchScreenRight.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY
        $TouchScreenJump.visibility_mode = TouchScreenButton.VISIBILITY_TOUCHSCREEN_ONLY


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
