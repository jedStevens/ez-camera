extends Spatial

var styles = ["bald"]
var current_style = 0

var rot_speed = 0.25


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var hair_styles = list_files_in_directory("res://characters/hair")
	for s in hair_styles:
		if s.ends_with(".msh"):
			styles.append(s)
	
	set_process(true)

func _on_shirt_color_color_changed( color ):
	get_node("ArmLow/Skeleton/HumanLow").get_mesh().surface_get_material(2).set_parameter(FixedMaterial.PARAM_DIFFUSE, color)


func _on_pants_color_color_changed( color ):
	get_node("ArmLow/Skeleton/HumanLow").get_mesh().surface_get_material(1).set_parameter(FixedMaterial.PARAM_DIFFUSE, color)


func _on_skin_color_color_changed( color ):
	get_node("ArmLow/Skeleton/HumanLow").get_mesh().surface_get_material(3).set_parameter(FixedMaterial.PARAM_DIFFUSE, color)


func _on_boots_color_color_changed( color ):
	get_node("ArmLow/Skeleton/HumanLow").get_mesh().surface_get_material(0).set_parameter(FixedMaterial.PARAM_DIFFUSE, color)

func _on_hair_changed( style ):
	if str(style) == "bald":
		var mesh = Mesh.new()
		get_node("ArmLow/Skeleton/hair/mesh").set_mesh(mesh)
		current_style = 0
		return
	elif style == "next":
		current_style += 1
		current_style = clamp(current_style, 0, styles.size()-1)
	elif style == "prev":
		current_style -= 1
		current_style = clamp(current_style, 0, styles.size()-1)
	
	var mesh = load("res://characters/hair/"+styles[current_style])
	get_node("ArmLow/Skeleton/hair/mesh").set_mesh(mesh)

func set_hairstyle(style):
	print("Set style #", style)
	current_style = style
	current_style = clamp(current_style, 0, styles.size()-1)
	var mesh = load("res://characters/hair/"+styles[current_style])
	get_node("ArmLow/Skeleton/hair/mesh").set_mesh(mesh)

func list_files_in_directory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)
	
	dir.list_dir_end()
	
	return files

func _on_hair_left_pressed():
	_on_hair_changed("prev")

func _on_hair_right_pressed():
	_on_hair_changed("next")

func _on_hair_color_color_changed( color ):
	get_node("ArmLow/Skeleton/hair/mesh").get_material_override().set_parameter(FixedMaterial.PARAM_DIFFUSE, color)

func get_hairstyle():
	return current_style