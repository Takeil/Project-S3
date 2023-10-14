extends Control

@export var page: Node

@export var label_template : PackedScene
@export var image_template : PackedScene
@export var button_template : PackedScene

var title := get_title()
var story : String
var curr_page : int

var title_label
var page_number_label
var page_container
var story_log_label
var scroll_container
var music_stream_player
var narration_stream_player
var animator

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

func set_story(story_title: String):
	# Get Title override
	animator.play("open")
	story = load_file("res://stories/" + story_title + "/story.txt")
	var extracted_title = _get_string_between(story, "<title>", "</title>")
	title = extracted_title.strip_edges()
	if title != "":
		title_label.text = title
	
	move_to_page(1)

func move_to_page(page_num: int) -> void:
	var page_content = _get_string_between(story, "<" + str(page_num) + ">", "</" + str(page_num) + ">")

	if page_content == "":
		set_log_text("Page " + str(page_num) + " Does Not Exist")
		print("Page " + str(page_num) + " Does Not Exist")
	else:
		page_number_label.text = str(page_num)
		setup_page(page_content)
		curr_page = page_num

func close_story():
	narration_stream_player.stop()
	music_stream_player.stop()
	animator.play("close")

func setup_page(info: String):
	var dat = info
	var values = []
	var types = []
	
	var loop_breaker = 0
	
	while true:
		dat = dat.strip_edges()
		loop_breaker += 1
		var type = _get_string_between(dat, "<", ">")
		var value = _get_string_between(dat, "<" + type + ">", "</" + type + ">")
		
		if value != "" and type != "":
			values.append(value.strip_edges())
			types.append(type)

		if loop_breaker == 100 || value.length() + 5 + (type.length() * 2) > dat.length():
			break

		dat = dat.substr(value.length() + 5 + (type.length() * 2))
	
	#print(values)
	#print(types)
	
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
			"p":
				node = label_template.instantiate()
				node.text = values[i]
				page_container.add_child(node)
			"img":
				node = image_template.instantiate()
				var file = FileAccess;
				if file.file_exists("res://stories/"+title+"/images/"+values[i]):
					node.texture = load("res://stories/"+title+"/images/"+values[i])
					page_container.add_child(node)
				else:
					print("res://stories/"+title+"/images/"+values[i]+" Does Not Exists")
			"btn":
				var page_number = _get_string_between(values[i],"[","]")
				
				if not page_number == "":
					node = button_template.instantiate()
					var button_text = values[i].left(values[i].find("["))
					
					node.text = button_text
					
					node.pressed.connect(move_to_page.bind(page_number.to_int()))
					
					page_container.add_child(node)
			"mus":
				var file = FileAccess
				if file.file_exists("res://stories/"+title+"/music/"+values[i]):
					var music = load("res://stories/"+title+"/music/"+values[i])
					music.set_loop(true)
					
					if (music == music_stream_player.stream and music_stream_player.playing):
						continue
					
					music_stream_player.stream = music
					music_stream_player.play()
				else:
					print("res://stories/"+title+"/music/"+values[i]+" Does Not Exists")
			"nar":
				var file = FileAccess
				if file.file_exists("res://stories/"+title+"/narration/"+values[i]):
					var narration = load("res://stories/"+title+"/narration/"+values[i])
					narration.set_loop(false)
					
					narration_stream_player.stream = narration
					narration_stream_player.play()
				else:
					print("res://stories/"+title+"/narration/"+values[i]+" Does Not Exists")
		
		if node != null:
			var _animator = node.get_node("AnimationPlayer")
			_animator.play("fade_in")

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

func _get_string_between(string: String, first: String, end: String) -> String:
	var from: int = string.find(first) + first.length()
	var to: int = string.find(end)
	
	# Check if either 'first' or 'end' substrings are not found
	if (from == -1 || to == -1):
		return ""
	
	return string.substr(from, to - from)

#This could be very very long
func load_file(file_path: String) -> String:
	var file = FileAccess
	var file_text = ""
	
	if file.file_exists(file_path):
		file_text = file.get_file_as_string(file_path)
	else:
		print("Failed to open the file: ", file_path)
	
	return file_text

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
