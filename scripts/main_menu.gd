extends Control

@export var book_template : PackedScene
var books_holder

var story_node
var dir = FileAccess
var folder_dir = "res://stories/"

func _ready():
	story_node = get_owner().get_node("Story")
	books_holder = $Body/ScrollContainer/MarginContainer/HBoxContainer
	var dir = DirAccess.open(folder_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				var node = book_template.instantiate()
				
				node.pressed.connect(story_node.set_story.bind(file_name))
				node.texture_normal = load("res://stories/"+file_name+"/images/cover.png")
				node.get_child(0).text = file_name
				
				books_holder.add_child(node)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
