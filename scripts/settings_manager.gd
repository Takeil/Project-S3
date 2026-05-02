extends Control

var animator: AnimationPlayer

var story_node : StoryManager
var change_to_page_value = 0

var music_bus = AudioServer.get_bus_index("Music")
var narration_bus = AudioServer.get_bus_index("Narration")
var effect_bus = AudioServer.get_bus_index("Effects")
var spin_box

var settings_file_path = "user://settings.sav"

var settings_data = {
	"music": 1,
	"narration": 1,
	"effect": 1,
	"font_size": 0.5,
}

func _ready():
	load_settings()
	story_node = get_owner().get_node("Story")
	spin_box = $SettingsPage/SettingsPageBackground/VBoxContainer/TurnPageControl/HBoxContainer/SpinBox
	
	animator = $AnimationPlayer
	
	AudioServer.set_bus_volume_db(music_bus, settings_data["music"])
	$SettingsPage/SettingsPageBackground/VBoxContainer/MusicControl/VBoxContainer/MusicVolume.value = settings_data["music"]
	
	AudioServer.set_bus_volume_db(narration_bus, settings_data["narration"])
	$SettingsPage/SettingsPageBackground/VBoxContainer/MusicControl/VBoxContainer/NarrationVolume.value = settings_data["narration"]
	
	AudioServer.set_bus_volume_db(effect_bus, settings_data["effect"])
	$SettingsPage/SettingsPageBackground/VBoxContainer/MusicControl/VBoxContainer/EffectVolume.value = settings_data["effect"]
	
	$SettingsPage/SettingsPageBackground/VBoxContainer/FontControl/VBoxContainer/FontScroll.value = settings_data["font_size"]	

func open():
	animator.play("open")

func close():
	animator.play("close")

func _on_settings_button_pressed():
	open()

func _on_settings_background_pressed():
	close()

func _on_button_pressed() -> void:
	close()
	story_node.move_to_page(change_to_page_value)

func _on_spin_box_value_changed(value):
	change_to_page_value = value

func page_changed():
	pass

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

func _on_effect_volume_value_changed(value):
	
	settings_data["effect"] = value
	save_settings()
	
	AudioServer.set_bus_volume_db(effect_bus, value)
	if value == -30:
		AudioServer.set_bus_mute(effect_bus, true)
	else:
		AudioServer.set_bus_mute(effect_bus, false)

func _on_font_size_changed(value):
	settings_data["font_size"] = value
	Global.story_theme.set_font_size("font_size","Button", (value / 100) * 40)
	Global.story_theme.set_font_size("font_size","CheckBox", (value / 100) * 40)
	Global.story_theme.set_font_size("font_size","Label", (value / 100) * 40)
	Global.story_theme.set_font_size("font_size","LineEdit", (value / 100) * 40)
	Global.story_theme.set_font_size("bold_font_size","RichTextLabel", (value / 100) * 40)
	Global.story_theme.set_font_size("bold_italics_font_size","RichTextLabel", (value / 100) * 40)
	Global.story_theme.set_font_size("italics_font_size","RichTextLabel", (value / 100) * 40)
	Global.story_theme.set_font_size("mono_font_size","RichTextLabel", (value / 100) * 40)
	Global.story_theme.set_font_size("normal_font_size","RichTextLabel", (value / 100) * 40)
	Global.story_theme.set_font_size("font_size","TextEdit", (value / 100) * 40)
	
	Global.type_theme.set_font_size("font_size","Button", (value / 100) * 40)
	Global.type_theme.set_font_size("font_size","CheckBox", (value / 100) * 40)
	Global.type_theme.set_font_size("font_size","Label", (value / 100) * 40)
	Global.type_theme.set_font_size("font_size","LineEdit", (value / 100) * 40)
	Global.type_theme.set_font_size("bold_font_size","RichTextLabel", (value / 100) * 40)
	Global.type_theme.set_font_size("bold_italics_font_size","RichTextLabel", (value / 100) * 40)
	Global.type_theme.set_font_size("italics_font_size","RichTextLabel", (value / 100) * 40)
	Global.type_theme.set_font_size("mono_font_size","RichTextLabel", (value / 100) * 40)
	Global.type_theme.set_font_size("normal_font_size","RichTextLabel", (value / 100) * 40)
	Global.type_theme.set_font_size("font_size","TextEdit", (value / 100) * 40)
	save_settings()

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
