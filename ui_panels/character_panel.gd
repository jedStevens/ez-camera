extends Panel

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if event.scancode == KEY_TAB and event.pressed:
			set_ignore_mouse(true)
			set_hidden(not is_hidden())
