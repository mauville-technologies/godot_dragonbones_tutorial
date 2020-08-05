extends KinematicBody2D

var _gravity : float = 64

var _velocity : Vector2 = Vector2(0,0)
export(float) var _move_speed = 1000.0;
export(float) var _jump_strength = -1200.0;

onready var sprite = $Sprite

var walking : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.connect("dragon_anim_snd_event", self, '_get_sound_event')
	pass # Replace with function body.

func _physics_process(delta):
	_handle_input()
	_apply_gravity()
	_velocity = move_and_slide(_velocity, Vector2.UP, true)

func _apply_gravity():
	_velocity.y += _gravity

func _handle_input():
	if Input.is_action_pressed("ui_right"):
		_velocity.x = _move_speed
		if !walking:
			walking = true
			play_new_animation("Walk")		
			
	elif Input.is_action_pressed("ui_left"):
		_velocity.x = -_move_speed
		if !walking:
			walking = true
			play_new_animation("Walk")	
	else:
		play_new_animation("TPose")		
		_velocity.x = 0
		walking = false
		
	if Input.is_action_pressed("ui_accept"):
		_velocity.y = _jump_strength
		play_new_animation("Jump")		

func play_new_animation(animation_name : String):
	if self.get("playback/curr_animation") != animation_name:
		sprite.stop_all()
		sprite.set("playback/curr_animation", animation_name)
		sprite.set("playback/loop", -1)
		sprite.play(true) 

func _get_sound_event(_animation_name: String, _sound_name : String):
	print(_animation_name)
	print(_sound_name)
	if _sound_name == 'left_step':
		$LeftFoot.seek(0)
		$LeftFoot.stop()
		$LeftFoot.play(-1.0)
	elif _sound_name == 'right_step':
		$RightFoot.stop()
		
		$RightFoot.seek(0)
		$RightFoot.play(-1.0)
	pass
