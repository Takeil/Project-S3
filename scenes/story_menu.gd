extends Control

@export var story_type_tbtn : TextureButton
@export var buttons : Array[TextureButton] = []
@export var story_information_rtl : RichTextLabel

@export var story_type_btn : TextureButton
@export var story_type_imgs : Array[Texture] = []

var animator
var book_background
var synopsis_rick_text_label
var buttons_container
var story_node

@export var button_template : PackedScene

func _ready():
	animator = $AnimationPlayer
	book_background = $BookBackground
	synopsis_rick_text_label = $MainBackground/TextVBoxContainer/PageContainer/SynopsisRichTextLabel
	buttons_container = $MainBackground/TextVBoxContainer/ButtonsHBoxContainer
	story_node = get_owner().get_node("Story")
	pass

func open(base_dir, file_name, image_texture):
	animator.play("open")
	
	var story = Global.load_file(base_dir + file_name + "/story.txt")
	
	if image_texture:
		book_background.texture = image_texture
	
	synopsis_rick_text_label.text = "[center]"
	var title_override = file_name
	if Global.source_contains(story,["<title>","</title>"]):
		synopsis_rick_text_label.text += "[font_size={30}][b]" + Global.get_string_between(story,"<title>","</title>") + "[/b][/font_size]\n"
		title_override = Global.get_string_between(story,"<title>","</title>").strip_edges()
	else:
		synopsis_rick_text_label.text += "[font_size={30}][b]" + file_name + "[/b][/font_size]\n"
	if Global.source_contains(story,["<author>","</author>"]):
		synopsis_rick_text_label.text += "[i]" + Global.get_string_between(story,"<author>","</author>") + "[/i]\n"
	if Global.source_contains(story,["<narrator>","</narrator>"]):
		synopsis_rick_text_label.text += "[i]" + Global.get_string_between(story,"<narrator>","</narrator>") + "[/i]\n"
	synopsis_rick_text_label.text += "[/center]\n"
	
	synopsis_rick_text_label.text += Global.get_string_between(story,"<synopsis>","</synopsis>")
	
	for i in buttons.size():
		if buttons[i].name.contains("Effects"):
			buttons[i].disabled = !(Global.source_contains(story,["<eff>","</eff>"]))
		if buttons[i].name.contains("Puzzle"):
			buttons[i].disabled = !(Global.source_contains(story,["<pwd>","</pwd>"]) || Global.source_contains("a",["<pat>","</pat>"]))
		if buttons[i].name.contains("Narration"):
			buttons[i].disabled = !(Global.source_contains(story,["<nar>","</nar>"]))
		if buttons[i].name.contains("Music"):
			buttons[i].disabled = !(Global.source_contains(story,["<mus>","</mus>"]))
	
	var story_type = ""
	if Global.source_contains(story, ["<story_type>", "</story_type>"]):
		story_type = Global.get_string_between(story,"<story_type>","</story_type>")
	
	match story_type.strip_edges():
		"linear":
			change_story_btn_texture(1)
		"mono_end":
			change_story_btn_texture(2)
		"multi_end":
			change_story_btn_texture(3)
		"loop":
			change_story_btn_texture(4)
		"adv_milti_end":
			change_story_btn_texture(5)
		_: #undefined
			change_story_btn_texture(0)
	
	for child in buttons_container.get_children():
		buttons_container.remove_child(child)
		child.queue_free()
	
	var node
	
	node = button_template.instantiate()
	node.text = "New"
	node.pressed.connect(story_node.set_story.bind(Global.folder_dir, file_name))
	node.pressed.connect(close)
	buttons_container.add_child(node)
	
	node = button_template.instantiate()
	var auto_save_page = Global.load_bookmark_page(title_override, "A")
	node.text = "Continue [" + str(auto_save_page) + "]"
	node.pressed.connect(story_node.set_story.bind(Global.folder_dir, file_name, auto_save_page))
	node.pressed.connect(close)
	buttons_container.add_child(node)

func close():
	animator.play("close")

func _on_back_button_pressed():
	close()

func change_story_btn_texture(index: int):
	story_type_btn.texture_normal = story_type_imgs[index]
