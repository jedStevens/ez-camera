extends KinematicBody

var to = Vector3(0,0,0)
var from = Vector3(0,0,0)

var to_move = Vector3(0,0,0)

var velocity = Vector3(0,0,0)
var move_speed = 4.5

var accum = 0

export(NodePath) var camera_base

signal targeted(position)

var previous_mouse_collision = Vector3(0,0,0)
var movement_min_threshold = 0.75

export(float) var crouch_speed_factor = 0.3

var last_flare = ""
var hip_blend = 0.5

func _ready():
	set_fixed_process(true)
	get_node("human_low/AnimationPlayer").connect("finished", self,  "chance_idle")

func chance_idle():
	var r = randf()
	if r < 0.25 and last_flare != "idle_3":
		get_node("human_low/AnimationPlayer").play("idle_3")
		last_flare = "idle_3"
	elif r < 0.4 and last_flare != "idle_2":
		get_node("human_low/AnimationPlayer").play("idle_2")
		last_flare = "idle_2"
	else:
		get_node("human_low/AnimationPlayer").play("idle")
		last_flare = ""

func _fixed_process(delta):
	var username_position_on_screen = get_node(camera_base).get_camera().unproject_position(get_node("username_position").get_global_transform().origin)
	get_node("username").set_pos(username_position_on_screen)
	
	var blockpos = previous_mouse_collision
	from = get_node(camera_base).get_camera().project_ray_origin(get_viewport().get_mouse_pos())
	to = from + get_node(camera_base).get_camera().project_ray_normal(get_viewport().get_mouse_pos())*10000
	var ds = PhysicsServer.space_get_direct_state(get_world().get_space())
	var col = ds.intersect_ray(from, to)

	if("collider" in col.keys()):
		var obj = col["collider"]
		var colpos = col["position"]
		blockpos = Vector3(float(colpos[0]), float(colpos[1]), float(colpos[2]))
	
	
	if Input.is_action_pressed("player_forward"):
		to_move.z += -1
	if Input.is_action_pressed("player_backward"):
		to_move.z += 0.6
	if Input.is_action_pressed("player_left"):
		to_move.x += -0.8
	if Input.is_action_pressed("player_right"):
		to_move.x += 0.8
	to_move = to_move.normalized()
	
	
	
	
	to_move = get_transform().basis * to_move
	
	if to_move.length() == 0:
		velocity *= 0.8
	else:
		velocity = (velocity + to_move).normalized()
	
	if Input.is_action_pressed("player_crouch"):
		velocity *= Vector3(crouch_speed_factor,crouch_speed_factor,crouch_speed_factor)
		get_node("human_low/AnimationPlayer").play("crouch")
	
	if get_translation().distance_to(blockpos) > movement_min_threshold:
		move(velocity * (Vector3(crouch_speed_factor,crouch_speed_factor,crouch_speed_factor) if Input.is_action_pressed("player_crouch") else Vector3(1,1,1))* delta * 4)
	to_move = Vector3(0,0,0)
	
	#look_at(previous_mouse_collision.linear_interpolate(blockpos, delta /2 ), Vector3(0,1,0))
	
	accum += delta
	previous_mouse_collision = blockpos

func get_base():
	return get_node("human_low")

func set_username(name):
	get_node("username/label").set_text(name)