extends Control

var text
var animator: AnimationPlayer
var story_node
var setting_node

func _ready():
	story_node = get_owner().get_node("Story")
	setting_node = get_owner().get_node("Story/Settings")
	text = $Body/Holder/TitleLabel
	animator = $AnimationPlayer

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

func save_bookmark(index : int):
	pass

func load_bookmark(index: int):
	pass

func _on_bookmarks_background_pressed():
	close_bookmarks()


func _on_save_bookmark_button_pressed():
	open_bookmarks("save")

func _on_load_bookmark_button_pressed():
	open_bookmarks("load")
