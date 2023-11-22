extends VBoxContainer

func setup(checkboxes):
	for i in checkboxes:
		var check_box = CheckBox.new()
		check_box.text = str(i)
		get_child(0).add_child(check_box)
