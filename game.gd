extends Spatial

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

export(NodePath) var player

export(NodePath) var camera_control

export(NodePath) var target


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	if session.savefile != null:
		load_from_save("user://"+session.savefile)
	else:
		load_from_save("res://characters/DemoMan.save")
	set_process_input(true)
	set_process(true)
	
	update_lights_based_on_camera()

func update_lights_based_on_camera():
	get_node("sun").set_shadow_param(DirectionalLight.SHADOW_PARAM_MAX_DISTANCE, get_node(camera_control).get_hand().get_translation().z + 2)
	
func load_from_save(save):
	print ("Loading from: ",save)
	
	var file = File.new()
	if not file.file_exists(save):
		print("Error this character doesn't exist, is their an issue with the UI?")
		get_tree().change_scene("res://character_customizer.tscn")
		return
	
	# Open existing file
	if file.open(save, File.READ) != 0:
		print("Error this character couldn't be opened")
		get_tree().change_scene("res://character_customizer.tscn")
		return
	
	# Get the data
	var data = {}
	data.parse_json(file.get_line())
	
	get_node(player).get_base()._on_shirt_color_color_changed(color_from_str(data["base"]["shirt"]))
	get_node(player).get_base()._on_pants_color_color_changed(color_from_str(data["base"]["pants"]))
	get_node(player).get_base()._on_boots_color_color_changed(color_from_str(data["base"]["boots"]))
	get_node(player).get_base()._on_skin_color_color_changed(color_from_str(data["base"]["skin"]))
	get_node(player).get_base()._on_hair_color_color_changed(color_from_str(data["base"]["hair"]))
	get_node(player).get_base().set_hairstyle(int(data["base"]["hairstyle"]))
	get_node(player).set_username(data["name"])

func color_from_str(s):
	var vals = s.split(",")
	return Color(float(vals[0]),float(vals[1]),float(vals[2]),1)

func _on_camera_control_transform_changed():
	update_lights_based_on_camera()


func _process(delta):
	if get_node(player).get_translation().distance_to(get_node(player).previous_mouse_collision) < get_node(player).movement_min_threshold:
		var old_color = get_node(target).get_node("mesh").get_material_override().get_parameter(FixedMaterial.PARAM_DIFFUSE)
		old_color.a = 0.1
		get_node(target).get_node("mesh").get_material_override().set_parameter(FixedMaterial.PARAM_DIFFUSE, old_color)
	else:
		var old_color = get_node(target).get_node("mesh").get_material_override().get_parameter(FixedMaterial.PARAM_DIFFUSE)
		old_color.a = 0.8
		get_node(target).get_node("mesh").get_material_override().set_parameter(FixedMaterial.PARAM_DIFFUSE, old_color)
	
	get_node(target).look_at_from_pos(get_node(player).previous_mouse_collision, get_node(player).get_translation(),  Vector3(0,1,0))
	
	_on_camera_control_transform_changed()