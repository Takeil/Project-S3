extends Control

class_name StoryManager

@export var page: Node

@export var label_template : PackedScene
@export var image_template : PackedScene
@export var button_template : PackedScene
@export var password_template : PackedScene
@export var pattern_template : PackedScene

var title := get_title()
var story : String
var curr_page : int
var directory_prefix : String

var title_label
var page_number_label
var page_container
var story_log_label
var scroll_container
var music_stream_player
var narration_stream_player
var sound_stream_player
var animator
var bookmarks
var effects_manager : EffectsManager
var selected_theme : Theme = Global.get_theme("main")

# Music and Narration
var curr_music

# Temp vars
var temp_eff_list : Array

# Called when the node enters the scene tree for the first time.
func _ready():
	animator = $AnimationPlayer
	title_label = $Header/Title
	page_number_label = $Footer/PageNumber
	page_container = $Body/PageContainer/Page
	story_log_label = $Footer/StoryLog
	scroll_container = $Body/PageContainer
	music_stream_player = $Body/Audio/MusicStreamPlayer
	narration_stream_player = $Body/Audio/NarrationStreamPlayer
	sound_stream_player = $Body/Audio/SoundStreamPlayer
	bookmarks = $Bookmarks
	effects_manager = get_parent().get_node("Effects")

func set_story(prefix : String, story_title: String, _selected_theme : Theme, page_override : int = 0 ):
	animator.play("open")
	directory_prefix = prefix
	selected_theme = _selected_theme
	story = Global.load_file(prefix + story_title + "/story.txt")
	var extracted_title = Global.get_string_between(story, "<title>", "</title>")
	title = extracted_title.strip_edges()
	if title != "":
		title_label.text = title
	
	bookmarks.setup()
	move_to_page(page_override)

func move_to_page(page_num: int) -> void:
	bookmarks.save_bookmark("A")
	var page_content = Global.get_string_between(story, "<" + str(page_num) + ">", "</" + str(page_num) + ">")
	
	if page_content == "":
		set_log_text("Page " + str(page_num) + " Does Not Exist")
		print("Page " + str(page_num) + " Does Not Exist")
	else:
		page_number_label.text = str(page_num)
		setup_page(page_content)
		curr_page = page_num

func close_story():
	clear_page()
	narration_stream_player.stop()
	music_stream_player.stop()
	close_all_effects()
	animator.play("close")

func setup_page(info: String):
	var dat = info
	var values = []
	var types = []
	
	var loop_breaker = 0
	
	while true:
		dat = dat.strip_edges()
		loop_breaker += 1
		var type = Global.get_string_between(dat, "<", ">")
		var value = Global.get_string_between(dat, "<" + type + ">", "</" + type + ">")
		
		if value != "" and type != "":
			values.append(value.strip_edges())
			types.append(type)
	
		if loop_breaker == 100 || value.length() + 5 + (type.length() * 2) > dat.length():
			break
	
		dat = dat.substr(value.length() + 5 + (type.length() * 2))
	
	# Clear page and create new objects
	
	for child in page.get_children():
		if child is Button:
			child.disabled = true
		var _animator = child.get_node("AnimationPlayer")
		_animator.play("fade_out")
	
	await (get_tree().create_timer(0.5).timeout)
	
	scroll_container.scroll_to_top()
	scroll_container.set_v_scroll(0)
	
	await (get_tree().create_timer(0.5).timeout)
	
	clear_page()
	
	for i in range(values.size()):
		var node = null
		
		match types[i]:
			
			# Visual / Story Objects
			
			"p":
				node = label_template.instantiate()
				node.text = values[i]
				page_container.add_child(node)
			
			"img":
				if (directory_prefix == Global.main_dir):
					node = image_template.instantiate()
					
					var path = directory_prefix+title+"/images/"+values[i]
					var texture = load(path)
					node.texture = texture
					
					page_container.add_child(node)
					
				elif FileAccess.file_exists(directory_prefix+title+"/images/"+values[i]):
					node = image_template.instantiate()
					
					var path = directory_prefix+title+"/images/"+values[i]
					var file = FileAccess.open(path, FileAccess.READ)
					var image = Image.new()
					var t = ImageTexture.new()
					
					if (values[i].contains("jpg")):
						image.load_jpg_from_buffer(file.get_buffer(file.get_length()))
					elif (values[i].contains("png")):
						image.load_png_from_buffer(file.get_buffer(file.get_length()))
					
					t.set_image(image)
					node.texture = t
					page_container.add_child(node)
				else:
					print(directory_prefix+title+"/images/"+values[i]+" Does Not Exist!")
			
			"btn":
				var page_number = Global.get_string_between(values[i],"[","]")
				
				if not page_number == "":
					node = button_template.instantiate()
					var button_text = values[i].left(values[i].find("["))
					
					node.text = button_text
					
					node.pressed.connect(move_to_page.bind(page_number.to_int()))
					
					page_container.add_child(node)
			
			"pwd":
				# Placeholder_text , correct_page, incorrect_page
				var data = Global.get_string_between(values[i],"[","]").split(",")
				
				if (data.size() != 3):
					print("Improper Password Format!")
					#improper format
					continue
				
				node = password_template.instantiate()
				node.get_child(0).placeholder_text = values[i].left(values[i].find("["))
				node.get_child(1).pressed.connect(password_button.bind(node.get_child(0), str(data[0]), data[1], data[2]))
				
				page_container.add_child(node)
			
			"pat":
				var data = Global.get_string_between(values[i],"[","]").split(",")
				
				if (data.size() != 3):
					print("Improper Pattern Format!")
					#improper format
					continue
					
				print(data[0].length())
				node = pattern_template.instantiate()
				node.setup(data[0].length())
				node.get_child(1).pressed.connect(pattern_button.bind(node.get_child(0), str(data[0]), data[1], data[2]))
				page_container.add_child(node)
			
			# Audio / Music Players
			
			"mus":
				if (directory_prefix == Global.main_dir):
					var path = directory_prefix+title+"/music/"+values[i]
					var music = load(path)
					
					if (curr_music == values[i] and music_stream_player.playing):
						continue
					
					curr_music = values[i]
					music_stream_player.stream = music
					music_stream_player.play()
				
				elif FileAccess.file_exists(directory_prefix+title+"/music/"+values[i]):
					
					var path = directory_prefix+title+"/music/"+values[i]
					var file = FileAccess.open(path, FileAccess.READ)
					var music = AudioStreamMP3.new()
					music.data = file.get_buffer(file.get_length())
					music.set_loop(true)
					
					if (curr_music == values[i] and music_stream_player.playing):
						continue
					
					curr_music = values[i]
					music_stream_player.stream = music
					music_stream_player.play()
				else:
					print(directory_prefix+title+"/music/"+values[i]+" Does Not Exist!")
			
			"nar":
				if (directory_prefix == Global.main_dir):
					var path = directory_prefix+title+"/narration/"+values[i]
					var narration = load(path)
					
					narration_stream_player.stream = narration
					narration_stream_player.play()
					
				elif FileAccess.file_exists(directory_prefix+title+"/narration/"+values[i]):
					
					var path = directory_prefix+title+"/narration/"+values[i]
					var file = FileAccess.open(path, FileAccess.READ)
					var narration = AudioStreamMP3.new()
					narration.data = file.get_buffer(file.get_length())
					narration.set_loop(false)
					
					narration_stream_player.stream = narration
					narration_stream_player.play()
				else:
					print(directory_prefix+title+"/narration/"+values[i]+" Does Not Exist!")
			
			"snd":
				if FileAccess.file_exists(directory_prefix+title+"/sound/"+values[i]):
					
					var path = directory_prefix+title+"/sound/"+values[i]
					var file = FileAccess.open(path, FileAccess.READ)
					var sound = AudioStreamMP3.new()
					sound.data = file.get_buffer(file.get_length())
					sound.set_loop(false)
					
					sound_stream_player.stream = sound
					sound_stream_player.play()
				else:
					print(directory_prefix+title+"/sound/"+values[i]+" Does Not Exist!")
			
			
			# Visual Effects
			
			"eff":
				effects_manager.open_particle(values[i])
				temp_eff_list.append(values[i])
		
		if node != null:
			node.set_theme(selected_theme)
			var _animator = node.get_node("AnimationPlayer")
			_animator.play("fade_in")
	
	for item in effects_manager.effect_list:
		if temp_eff_list.find(item.to_lower()) == -1:
			effects_manager.close_particle(item)
	temp_eff_list.clear()
	
	if (types.find("mus") == -1):
		music_stream_player.stop()

func close_all_effects():
	for item in effects_manager.effect_list:
		effects_manager.close_particle(item)

func password_button(text_edit_node, correct_answer, correct, incorrect):
	if (text_edit_node.text.to_lower() == correct_answer.to_lower()):
		move_to_page(int(correct))
	else:
		move_to_page(int(incorrect))

func pattern_button(parent_node, pattern, correct, incorrect):
	var code = ""
	for child in parent_node.get_children():
		if(child.is_pressed()):
			code += "1"
		else:
			code += "0"
	if(code == pattern):
		move_to_page(int(correct))
	else:
		move_to_page(int(incorrect))
	return 0

# Define a function to get the title
func get_title() -> String:
	return title

# Define a function to get the current page
func get_current_page() -> int:
	return curr_page

func clear_page():
	narration_stream_player.stop()
	for child in page.get_children():
		page.remove_child(child)
		child.queue_free()

var log_timer = null
func set_log_text(text: String):
	# Clear the existing timer, if any
	if log_timer:
		log_timer.stop()
		log_timer.queue_free()

	# Set the text
	story_log_label.text = text

	# Start a new timer to clear the text after 2 seconds
	log_timer = Timer.new()
	log_timer.wait_time = 2.0
	log_timer.one_shot = true
	log_timer.timeout.connect(_on_log_timer_timeout)
	add_child(log_timer)
	log_timer.start()
 
func _on_log_timer_timeout():
	# Clear the text when the timer times out
	story_log_label.text = ""

func _on_back_button_pressed():
	close_story()
