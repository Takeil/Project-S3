extends Control

@export var book_template : PackedScene
var books_holder

var story_node
var story_menu_node

func _ready():
	OS.request_permissions()
	#await get_tree().on_request_permissions_result
	
	story_node = get_owner().get_node("Story")
	story_menu_node = get_owner().get_node("StoryMenu")

	books_holder = $Body/ScrollContainer/MarginContainer/Container
	
	var dir = DirAccess.open(Global.main_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found in main directory: " + file_name)
				
				var node = book_template.instantiate()
				var path = (Global.main_dir + file_name + "/cover.png")
				
				var imported_resource = load(path)
				node.get_child(0).texture = imported_resource
				
				#node.pressed.connect(story_node.set_story.bind(Global.main_dir, file_name))
				node.pressed.connect(story_menu_node.open.bind(Global.main_dir, file_name, imported_resource))
				node.get_child(1).text = file_name
				
				books_holder.add_child(node)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access: " + Global.main_dir)

	dir = DirAccess.open(Global.folder_dir)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir():
				print("Found in local directory: " + file_name)
				
				var node = book_template.instantiate()
				var path = (Global.folder_dir + file_name + "/cover.png")
				
				var t = ImageTexture.new()
				
				if (FileAccess.file_exists(path)):
					var file = FileAccess.open(path, FileAccess.READ)
					var image = Image.new()
					image.load_png_from_buffer(file.get_buffer(file.get_length()))
					
					t.set_image(image)
					node.get_child(0).texture = t
				
				#node.pressed.connect(story_node.set_story.bind(Global.folder_dir, file_name))
				node.pressed.connect(story_menu_node.open.bind(Global.folder_dir, file_name, t))
				node.get_child(1).text = file_name
				
				books_holder.add_child(node)
			else:
				print("Found file: " + file_name)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path: " + Global.folder_dir)
	
