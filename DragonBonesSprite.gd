extends GDDragonBones


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
    if self.get("playback/curr_animation") != "Run" :
        stop_all()
        set("playback/curr_animation", "Run")
        set("playback/loop", -1)                
        play(true)
