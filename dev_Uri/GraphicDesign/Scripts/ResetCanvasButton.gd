extends Button

onready var player = get_node("/root/CreationScene/PlayerBody")
onready var scene = get_node("/root/Main")

func _process(delta):
	if Input.is_key_pressed(KEY_R):
		clear_canvas()

func click():
	clear_canvas()

func clear_canvas():
	for clone in player.clones:
		scene.remove_child(clone)
