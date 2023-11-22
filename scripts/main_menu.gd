extends Control

@export var book_template : PackedScene
var books_holder

var story_node
var folder_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Pluma/stories/"

func _ready():
	OS.request_permissions()
	#await get_tree().on_request_permissions_result
	
	story_node = get_owner().get_node("Story")
	books_holder = $Body/ScrollContainer/MarginContainer/Container
	var dir = DirAccess.open(folder_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found directory: " + file_name)
				var node = book_template.instantiate()
				
				var path = (OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Pluma/stories/"+file_name+"/cover.png")
				if (FileAccess.file_exists(path)):
					var file = FileAccess.open(path, FileAccess.READ)
					var image = Image.new()
					var t = ImageTexture.new()
					image.load_png_from_buffer(file.get_buffer(file.get_length()))
					
					t.set_image(image)
					node.get_child(0).texture = t
				
				node.pressed.connect(story_node.set_story.bind(file_name))
				node.get_child(1).text = file_name
				
				books_holder.add_child(node)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
