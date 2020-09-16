extends Node2D

onready var rig = $CanvasLayer/DemoRig
onready var slot_selection = $CanvasLayer/PanelContainer/Panel/VBoxContainer/HBoxContainer4/SlotSelection
onready var armature_selection = $CanvasLayer/PanelContainer/Panel/VBoxContainer/HBoxContainer/ArmatureSelection
onready var animation_selection = $CanvasLayer/PanelContainer/Panel/VBoxContainer/HBoxContainer2/AnimationSelection
onready var progress_selection = $CanvasLayer/PanelContainer/Panel/VBoxContainer/HBoxContainer3/ProgressSelection
onready var fadetime = $CanvasLayer/PanelContainer/Panel/VBoxContainer/FadeSettings/VBoxContainer/FadeTime
onready var fadeloop = $CanvasLayer/PanelContainer/Panel/VBoxContainer/FadeSettings/VBoxContainer2/FadeLoop
onready var fadelayer = $CanvasLayer/PanelContainer/Panel/VBoxContainer/FadeSettings/VBoxContainer3/FadeLayer
onready var fadegroup = $CanvasLayer/PanelContainer/Panel/VBoxContainer/FadeSettings/VBoxContainer4/FadeGroup
onready var fademode = $CanvasLayer/PanelContainer/Panel/VBoxContainer/FadeSettings/VBoxContainer5/FadeMode
onready var slot_colorpicker = $CanvasLayer/PanelContainer/Panel/VBoxContainer/SlotColor
onready var color_label = $CanvasLayer/PanelContainer/Panel/VBoxContainer/HBoxContainer6/Label
onready var events = $CanvasLayer/PanelContainer/Panel/VBoxContainer/RichTextLabel

var current_slot : String = ''
var current_armature : String = ''
var current_animation : String = ''
var time = 0.0;
var count : int = 0

var child_armatures = {};

func _get_current_armature() -> GDArmatureDisplay:
	return rig.get_armature() as GDArmatureDisplay if current_armature == rig.get_armature().name else rig.get_armature().get_slot(child_armatures[current_armature]).get_child_armature() as GDArmatureDisplay

# Called when the node enters the scene tree for the first time.
func _ready():

	rig.set('resource', load("res://assets/character/Character_ske.json"))
	rig.connect("dragon_anim_loop_complete", self, "_anim_loop_event")
	_build_armature_list()
	

	fademode.add_item('FadeOut_All', GDArmatureDisplay.FadeOut_All)
	fademode.add_item('FadeOut_None', GDArmatureDisplay.FadeOut_None)
	fademode.add_item('FadeOut_SameGroup', GDArmatureDisplay.FadeOut_SameGroup)
	fademode.add_item('FadeOut_SameLayer', GDArmatureDisplay.FadeOut_SameLayer)
	fademode.add_item('FadeOut_SameLayerAndGroup', GDArmatureDisplay.FadeOut_SameLayerAndGroup)
	fademode.add_item('FadeOut_Single', GDArmatureDisplay.FadeOut_Single)

	#rig.set_process(true)
func _anim_loop_event(animation : String):
	events.text = "%s\n%s" % [animation, events.text]
	pass
	
func _build_armature_list():
	child_armatures = {}
	armature_selection.clear()
	
	armature_selection.add_item(rig.get_armature().name)
	
	for slot in rig.get_armature().get_slots().values():
		var converted_slot = slot as GDSlot        
		if converted_slot.get_child_armature():
			child_armatures[converted_slot.get_child_armature().name] = converted_slot.get_slot_name()
			armature_selection.add_item(converted_slot.get_child_armature().name)
	
	_amature_changed(0)	
	pass
	
func _amature_changed(index):
	current_armature = armature_selection.get_item_text(index)

	# update animations dropdown
	animation_selection.clear()

	for animation in _get_current_armature().get_animations():
		animation_selection.add_item(animation)

	# update slot dropdown
	slot_selection.clear()
	for slot in _get_current_armature().get_slots().values():
		var converted_slot = slot as GDSlot
		slot_selection.add_item(converted_slot.get_slot_name())
		
	_slot_selected(0)
	_animation_selected(0)


func _slot_selected(index):
	current_slot = slot_selection.get_item_text(index)
	#slot_colorpicker.visible = _get_current_armature().get_slot(current_slot).get_child_armature() == null
	
	if slot_colorpicker.visible:
		color_label.text = 'Slot Color Modifier'
		color_label.modulate = Color(1,1,1,1)
	else:
		color_label.text = 'Slot Color Modifier not available for child armatures'
		color_label.modulate = Color(1,0,0,1)
		
		
	slot_colorpicker.color = _get_current_armature().get_slot(current_slot).get_display_color_multiplier()
	pass # Replace with function body.

	
func _animation_selected(index):
	current_animation = animation_selection.get_item_text(index)

func _play():
	_get_current_armature().thaw()    
	_get_current_armature().play(current_animation, fadeloop.value);


func _play_from_progress():
	_get_current_armature().play_from_progress(current_animation, progress_selection.value, fadeloop.value)
	pass # Replace with function body.


func _stop_selected():
	_get_current_armature().stop(current_animation,true)

func stop_all():
	_get_current_armature().stop_all_animations(true, true)

func _fadein():
	_get_current_armature().fade_in(current_animation,
	 fadetime.value, fadeloop.value, fadelayer.value, fadegroup.text, fademode.selected)

func _cycle_armature_slot(next : bool):
	_get_current_armature().get_slot(current_slot).next_display() if next else _get_current_armature().get_slot(current_slot).previous_display()
	if _get_current_armature().get_slot(current_slot).get_child_armature():
		if _get_current_armature().get_slot(current_slot).get_child_armature().name == current_armature:
			_build_armature_list()
			
	
func _play_animation_on_child():
	_build_armature_list()
	pass


func _physics_process(_delta):
	pass
	count += 1

	var points = 100
	var current_point = count % points

	var radius = Vector2(300, 0)
	var center = Vector2(0,0)

	var step = 2 * PI / points

	var spawn_pos = center + radius.rotated(step * current_point)
	var mouse_offset = (get_global_mouse_position() - rig.position)
	mouse_offset = Vector2(mouse_offset.x / rig.scale.x, mouse_offset.y / rig.scale.y) 
	
	rig.get_armature().set_ik_constraint("head_ik", mouse_offset);    
	
	rig.get_armature().get_bone("github_bone").set_bone_position(spawn_pos)




func _on_slot_color_changed(color):
	_get_current_armature().get_slot(current_slot).set_display_color_multiplier(color)
	
	

