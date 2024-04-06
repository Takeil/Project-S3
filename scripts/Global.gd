extends Node

var folder_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS) + "/Pluma/stories/"
var main_dir = "res://stories/"

var main_theme : Theme = load("res://themes/main_theme.tres")
var type_theme : Theme = load("res://themes/type_theme.tres")

func get_string_between(string: String, first: String, end: String) -> String:
	var from: int = string.find(first) + first.length()
	var to: int = string.find(end)
	
	# Check if either 'first' or 'end' substrings are not found
	if (from == -1 || to == -1):
		return ""
	
	return string.substr(from, to - from)

func source_contains(source : String, list : Array):
	for x in list.size():
		if !source.contains(list[x]):
			return false
	return true

func load_file(file_path: String) -> String:
	var file = FileAccess
	var file_text = ""
	
	if file.file_exists(file_path):
		file_text = file.get_file_as_string(file_path)
	else:
		print("Failed to open the file: ", file_path)
	
	return file_text

func load_bookmark_page(title : String, index : String, default : int = 0):
	var path = "user://" + title + "_data.sav"
	var bookmarks
	if (FileAccess.file_exists(path)):
		var f = FileAccess
		if f.file_exists(path):
			f = FileAccess.open(path, FileAccess.READ)
			bookmarks = f.get_var()
			print(bookmarks)
		return bookmarks[index]
	else:
		return default

func open_message(message : String, time : float = 0.5):
	pass

func get_theme(type: String = "main"):
	if (type == "main"):
		return main_theme
	elif (type == "type"):
		return type_theme
	else:
		return main_theme
