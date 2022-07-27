extends Node2D

onready var symbol_body = get_node("/root/CreationScene/Symbol")
onready var symbol_holder = get_node("/root/CreationScene/Symbols")
onready var settings = get_node("/root/CreationScene/Settings")
onready var square = get_node("/root/CreationScene/GridSquare")

func _ready():
	create_grid()
	place_symbols()

func create_grid():
	for i in range(settings.GRID_LENGTH):
		for j in range(settings.GRID_LENGTH):
			var clone = square.duplicate()
			clone.scale = Vector2(settings.GRID_SQUARE_LENGTH, settings.GRID_SQUARE_LENGTH)
			clone.position = Vector2((settings.GRID_MARGIN+clone.scale.x/2)+(settings.GRID_SQUARE_MARGIN*j), (settings.GRID_MARGIN+clone.scale.x/2)+(settings.GRID_SQUARE_MARGIN*i))
			clone.z_index = -20
			add_child(clone)

func place_symbols():
	var count = 0
	for icon in symbol_holder.get_children():
		icon.visible = true
		symbol_holder.remove_child(icon)
		var clone = symbol_body.duplicate()
		icon.position = Vector2.ZERO
		clone.add_child(icon)
		clone.position.y = 530
		clone.position.x = 65+(85*count)
		add_child(clone)
		count += 1
