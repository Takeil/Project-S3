extends Control

var animator: AnimationPlayer

var story_node
#var page_change = false
var change_to_page_value = 0

var music_bus = AudioServer.get_bus_index("Music")
var narration_bus = AudioServer.get_bus_index("Narration")

var settings_file_path = "user://settings.sav"

var settings_data = {
	"music": 1,
	"narration": 1
}

func _ready():
	load_settings()
	story_node = get_owner().get_node("Story")
	animator = $AnimationPlayer
	
	AudioServer.set_bus_volume_db(music_bus, settings_data["music"])
	$SettingsPage/SettingsPageBackground/VBoxContainer/MusicControl/VBoxContainer/MusicVolume.value = settings_data["music"]
	
	AudioServer.set_bus_volume_db(narration_bus, settings_data["narration"])
	$SettingsPage/SettingsPageBackground/VBoxContainer/MusicControl/VBoxContainer/NarrationVolume.value = settings_data["narration"]

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
	#if value == story_node.get_current_page():
		#page_change = false
	#else:
		#page_change = true
	change_to_page_value = value

func _on_move_page_button_pressed():
	close()
	#if (page_change):
	#	page_change = false
	story_node.move_to_page(change_to_page_value)

func _on_music_volume_value_changed(value):
	
	settings_data["music"] = value
	save_settings()
	
	AudioServer.set_bus_volume_db(music_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(music_bus, true)
	else:
		AudioServer.set_bus_mute(music_bus, false)

func _on_narration_volume_value_changed(value):
	
	settings_data["narration"] = value
	save_settings()
	
	AudioServer.set_bus_volume_db(narration_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(narration_bus, true)
	else:
		AudioServer.set_bus_mute(narration_bus, false)

func save_settings():
	var f = FileAccess.open(settings_file_path, FileAccess.WRITE)
	f.store_var(settings_data)

func load_settings():
	if (FileAccess.file_exists(settings_file_path)):
		var f = FileAccess
		if f.file_exists(settings_file_path):
			f = FileAccess.open(settings_file_path, FileAccess.READ)
			settings_data = f.get_var()
	else:
		save_settings()
