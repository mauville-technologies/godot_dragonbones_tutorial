extends Node2D

const demos = {
	'BasicEditor': 'res://WelcomeToTheGame.tscn',
	'InverseKinematics': 'res://Demo/InverseKinematics/MechBoard.tscn',
}


# Called when the node enters the scene tree for the first time.
func _ready():
	var count = 0
	var selected_index = 0
	for key in demos:
		$OptionButton.add_item(key)
		if get_tree().current_scene.filename == demos[key]:
			selected_index = count
		
		count += 1
		
	$OptionButton.select(selected_index)



func _on_OptionButton_item_selected(index):
	get_tree().change_scene(demos[$OptionButton.get_item_text(index)])
