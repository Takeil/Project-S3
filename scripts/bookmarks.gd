extends Control

var text
var animator: AnimationPlayer
var story_node
var setting_node
var title

@export var button_template : PackedScene

var button_container

func _ready():
	story_node = get_owner().get_node("Story")
	setting_node = get_owner().get_node("Story/Settings")
	text = $Body/Holder/TitleLabel
	animator = $AnimationPlayer
	button_container = $Body/Holder/HFlowContainer

func close_bookmarks():
	animator.play("close")

func open_bookmarks(type: String):
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
	
	# AUTO SAVE START
	var bookmark_name = "B_" + story_node.get_title() + "_A"
	var node = button_template.instantiate()
	if (SaveSystem.has(bookmark_name)):
		node.text = str(SaveSystem.get_var(bookmark_name)) 
	node.text += " (auto)"
	if (type == "load" and SaveSystem.has(bookmark_name)):
		node.disabled = false
		node.pressed.connect(load_bookmark.bind("A"))
	button_container.add_child(node)
	# AUTO SAVE END
	
	for i in 3:
		bookmark_name = "B_" + story_node.get_title() + "_" + str(i)
		
		node = button_template.instantiate()

		if (SaveSystem.has(bookmark_name)):
			node.text = str(SaveSystem.get_var(bookmark_name))
		
		if (type == "save"):
			node.disabled = false
			node.pressed.connect(save_bookmark.bind(i))
			
		elif (type == "load" and SaveSystem.has(bookmark_name)):
			node.disabled = false
			node.pressed.connect(load_bookmark.bind(i))

		button_container.add_child(node)

func _on_bookmarks_background_pressed():
	close_bookmarks()

func save_bookmark(index):
	var bookmark_name = "B_" + story_node.get_title() + "_" + str(index)
	SaveSystem.set_var(bookmark_name, story_node.get_current_page())
	close_bookmarks()
	story_node.set_log_text("Bookmark Saved!")

func load_bookmark(index):
	var bookmark_name = "B_" + story_node.get_title() + "_" + str(index)
	var page = SaveSystem.get_var(bookmark_name)
	close_bookmarks()
	story_node.move_to_page(page)
	
func _on_save_bookmark_button_pressed():
	open_bookmarks("save")

func _on_load_bookmark_button_pressed():
	open_bookmarks("load")
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var bookmark_name = "B_" + story_node.get_title() + "_A"
		SaveSystem.set_var(bookmark_name, story_node.get_current_page())
		get_tree().quit() # default behavior
