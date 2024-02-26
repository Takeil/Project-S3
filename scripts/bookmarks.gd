extends Control

var text
var animator: AnimationPlayer
var story_node
var setting_node
var title

@export var button_template : PackedScene

var button_container
var path

var bookmarks := {
	"A" : 1,
	"0" : 1,
	"1" : 1,
	"2" : 1
}

var is_open

func _ready():
	story_node = get_owner().get_node("Story")
	setting_node = get_owner().get_node("Story/Settings")
	text = $Body/Holder/TitleLabel
	animator = $AnimationPlayer
	button_container = $Body/Holder/HFlowContainer

func close_bookmarks():
	animator.play("close")
	
func setup():
	path = "user://" + story_node.get_title() + "_data.sav"
	bookmarks = load_bookmarks()

func open_bookmarks(type: String):
	setup()
	setting_node.animator.play("close")
	animator.play("open")
	
	if (type == "save"):
		text.text = "SAVE BOOKMARK"
		pass
	
	elif (type == "load"):
		text.text = "LOAD BOOKMARK"
		pass
	
	for child in button_container.get_children():
		button_container.remove_child(child)
		child.queue_free()
	
	# AUTO SAVE
	var node = button_template.instantiate()
	node.text = str(bookmarks["A"]) + " (auto)"
	if (type == "load"):
		node.disabled = false
		node.pressed.connect(load_bookmark_button.bind("A"))
	button_container.add_child(node)
	# AUTO SAVE END
	
	for i in 3:
		node = button_template.instantiate()
		node.text = str(bookmarks[str(i)])
		
		if (type == "save"):
			node.disabled = false
			node.pressed.connect(save_bookmark_button.bind(str(i)))
			
		elif (type == "load"):
			node.disabled = false
			node.pressed.connect(load_bookmark_button.bind(str(i)))
		
		button_container.add_child(node)

func _on_bookmarks_background_pressed():
	close_bookmarks()

func save_bookmark_button(index):
	save_bookmark(index)
	close_bookmarks()
	story_node.set_log_text("Bookmark Saved!")

func load_bookmark_button(index):
	load_bookmark(index)
	close_bookmarks()
	
func save_bookmark(index):
	bookmarks[index] = story_node.get_current_page()
	save_bookmarks_func()

func load_bookmark(index):
	var page = load_bookmark_func(index)
	story_node.move_to_page(page)

func _on_save_bookmark_button_pressed():
	open_bookmarks("save")

func _on_load_bookmark_button_pressed():
	open_bookmarks("load")

func auto_save():
	save_bookmark("A")

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_bookmark("A")
		get_tree().quit() # default behavior

func save_bookmarks_func():
	if (story_node.get_title() != null and path != null):
		var f = FileAccess.open(path, FileAccess.WRITE)
		f.store_var(bookmarks)

func load_bookmark_func(index):
	bookmarks = load_bookmarks()
	print(bookmarks)
	return bookmarks[index]

func load_bookmarks():
	var bkmrks = bookmarks
	if (FileAccess.file_exists(path)):
		var f = FileAccess
		if f.file_exists(path):
			f = FileAccess.open(path, FileAccess.READ)
			bkmrks = f.get_var()
	else:
		save_bookmarks_func()
	return bkmrks
