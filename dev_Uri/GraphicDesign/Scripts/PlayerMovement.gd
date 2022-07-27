extends KinematicBody2D

onready var settings = get_node("/root/CreationScene/Settings")
onready var main = get_node("/root/Main")
var grabbed_right = KinematicBody2D.new()
var grabbed_left = KinematicBody2D.new()

onready var right_timer = settings.PICKUP_DELAY
onready var left_timer = settings.PICKUP_DELAY

var right_size = Vector2()
var left_size = Vector2()

var clones = []

func _process(delta):
	var velocity = Vector2.ZERO
	if Input.is_key_pressed(KEY_UP):
		rotation_degrees = 0
		velocity += Vector2.UP
		move_grabbed("up")
	if Input.is_key_pressed(KEY_DOWN):
		rotation_degrees = 180
		velocity += Vector2.DOWN
		move_grabbed("down")
	if Input.is_key_pressed(KEY_LEFT):
		rotation_degrees = -90
		velocity += Vector2.LEFT
		move_grabbed("left")
	if Input.is_key_pressed(KEY_RIGHT):
		rotation_degrees = 90
		velocity += Vector2.RIGHT
		move_grabbed("right")
	# Moves the player and checks for collisions
	var collision = move_and_collide(velocity * settings.PLAYER_SPEED)
	# If key A is pressed, pick up the nearby item to the left hand
	if Input.is_key_pressed(KEY_D):
		grab(true, collision)
	# If key D is pressed, pick up the nearby item to the right hand
	if Input.is_key_pressed(KEY_A):
		grab(false, collision)
	boundry()
	
	if left_timer > 0:
		left_timer -= 1
	if right_timer > 0:
		right_timer -= 1

# Make sure the player can't go out of bounds by teleporting
# them to the other side of the map.
func boundry():
	var view = get_viewport().size
	if position.x > view.x:
		position.x = 0
	if position.x < 0:
		position.x = view.x
	if position.y > view.y:
		position.y = 0
	if position.y < 0:
		position.y = view.y

func move_grabbed(var pos: String):
	var right_offset = Vector2.ZERO # The offset for the item on the right hand
	var left_offset = Vector2.ZERO # The offset for the item on the left hand
	var rotation = 0
	if pos == "down":
		rotation = 180
		right_offset = Vector2(30, 30)
		left_offset = Vector2(-30, 30)
	if pos == "up":
		rotation = 0
		right_offset = Vector2(-30, -35)
		left_offset = Vector2(30, -35)
	if pos == "left":
		rotation = -90
		right_offset = Vector2(-25, 30)
		left_offset = Vector2(-30, -25)
	if pos == "right":
		rotation = 90
		right_offset = Vector2(30, -30)
		left_offset = Vector2(30, 30)
	# Adds the offsets
	grabbed_right.position = position + right_offset
	grabbed_left.position = position + left_offset
	# Rotates by the correct amount
	grabbed_right.rotation_degrees = rotation
	grabbed_left.rotation_degrees = rotation

func grab(left: bool, collision: KinematicCollision2D):
	# If grabbed right has no children, it means it's empty.
	if grabbed_right.get_child_count() != 0 and !left and right_timer == 0:
		grabbed_right.scale *= 2
		grabbed_right.z_index = -10
		grabbed_right.position = get_snapped_position(false)
		clones.append(grabbed_right)
		grabbed_right = KinematicBody2D.new()
		right_timer = settings.PICKUP_DELAY
	if grabbed_left.get_child_count() != 0 and left and left_timer == 0:
		grabbed_left.scale *= 2
		grabbed_left.z_index = -10
		grabbed_left.position = get_snapped_position(true)
		clones.append(grabbed_left)
		grabbed_left = KinematicBody2D.new()
		left_timer = settings.PICKUP_DELAY
	# If the collider exists, pick it up.
	if collision != null:
		if collision.collider != null:
			var collider = collision.collider
			if !left and grabbed_right != collider and right_timer==0:
				grabbed_right = collider.duplicate()
				main.add_child(grabbed_right)
				grabbed_right.get_children()[0].disabled = true
				grabbed_right.scale /= 2
				right_timer = settings.PICKUP_DELAY
			elif left and grabbed_left != collider and left_timer==0:
				grabbed_left = collider.duplicate()
				main.add_child(grabbed_left)
				grabbed_left.get_children()[0].disabled = true
				grabbed_left.scale /= 2
				left_timer = settings.PICKUP_DELAY

func get_snapped_position(left: bool) -> Vector2:
	var half_length = settings.GRID_SQUARE_LENGTH/2
	if left:
		var placement_x = int(((grabbed_left.position.x-settings.GRID_MARGIN)) / settings.GRID_SQUARE_MARGIN)
		var placement_y = int(((grabbed_left.position.y-settings.GRID_MARGIN)) / settings.GRID_SQUARE_MARGIN)
		var pos = Vector2(settings.GRID_MARGIN+half_length+((settings.GRID_SQUARE_MARGIN)*placement_x), settings.GRID_MARGIN+half_length+((settings.GRID_SQUARE_MARGIN)*placement_y))
		return pos
	else:
		var placement_x = int((grabbed_right.position.x-settings.GRID_MARGIN) / settings.GRID_SQUARE_MARGIN)
		var placement_y = int((grabbed_right.position.y-settings.GRID_MARGIN) / settings.GRID_SQUARE_MARGIN)
		var pos = Vector2(settings.GRID_MARGIN+half_length+(settings.GRID_SQUARE_MARGIN*placement_x), settings.GRID_MARGIN+half_length+(settings.GRID_SQUARE_MARGIN*placement_y))
		return pos
