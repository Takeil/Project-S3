extends Control

var animator: AnimationPlayer

var story_node
var page_change = false
var change_to_page_value = 0

var music_bus = AudioServer.get_bus_index("Music")
var narration_bus = AudioServer.get_bus_index("Narration")

func _ready():
	story_node = get_owner().get_node("Story")
	animator = $AnimationPlayer

func open():
	animator.play("open")

func close():
	animator.play("close")

func _on_settings_button_pressed():
	open()

func _on_settings_back_button_pressed():
	close()

func _on_settings_background_pressed():
	close()

func _on_spin_box_value_changed(value):
	if value == story_node.get_current_page():
		page_change = false
	else:
		page_change = true
		change_to_page_value = value

func _on_move_page_button_pressed():
	close()
	if (page_change):
		page_change = false
		story_node.move_to_page(change_to_page_value)

func _on_music_volume_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)


func _on_narration_volume_value_changed(value):
	AudioServer.set_bus_volume_db(narration_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(narration_bus, true)
	else:
		AudioServer.set_bus_mute(narration_bus, false)
