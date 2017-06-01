extends Spatial

# Game camera that raises input events from the user
# this is a symbol of the user in the game world

# it works like someone holding a camera at their face, 
# the base their shoulder, for 360 spining around the center
# the arm is their arm, for up and down angling
# the hand the their hand, for looking
# the camera is the actual camera

# imagine somone holding a selfie stick, but draw a line from shoulder to wrist
export(NodePath) var camera_base
export(NodePath) var camera_arm
export(NodePath) var camera_hand
export(NodePath) var camera

export(NodePath) var player
export(NodePath) var target

var panning = false

var max_cam_dist = 15

signal transform_changed

var min_arm_angle = -85
var max_arm_angle = -25

var zoom = Vector3(0,0,0)

func _ready():
	set_process_input(true)
	set_process(true)
	
	zoom = get_node(camera_hand).get_translation()

func _process(delta):
	get_node(camera_hand).set_translation(get_node(camera_hand).get_translation().linear_interpolate(zoom, delta))
	
	var target_look_at = get_node(player).get_translation()
	
	var player_t =  get_node(player).get_translation()
	if player_t.distance_to(target_look_at) > max_cam_dist:
		target_look_at = (target_look_at - player_t).normalized() * max_cam_dist + player_t
	
	set_translation(get_translation().linear_interpolate(target_look_at, delta))

func _input(event):
	# Camera Logic
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_WHEEL_DOWN:
			zoom *= Vector3(0,0,1.05)
			emit_signal("transform_changed")
			
		if event.button_index == BUTTON_WHEEL_UP:
			zoom *= Vector3(0,0,0.95)
			emit_signal("transform_changed")
			
		if event.button_index == BUTTON_MIDDLE:
			panning = event.pressed
			
	if event.type == InputEvent.MOUSE_MOTION:
		if panning and event.alt:
			var new_arm_angle = get_node(camera_arm).get_rotation() + Vector3(-event.relative_y * 0.01, 0, 0)
			new_arm_angle.x = clamp(new_arm_angle.x, deg2rad(min_arm_angle), deg2rad(max_arm_angle))
			get_node(camera_arm).set_rotation(new_arm_angle)
			emit_signal("transform_changed")
			
		elif panning:
			get_node(camera_base).set_rotation(get_node(camera_base).get_rotation() + Vector3(0,event.relative_x * 0.01, 0))
			emit_signal("transform_changed")

func get_hand():
	return get_node(camera_hand)

func get_camera():
	return get_node(camera)