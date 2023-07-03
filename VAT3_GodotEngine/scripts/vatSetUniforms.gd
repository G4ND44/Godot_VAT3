@tool
extends Node

@export var pulse: bool : set = set_pulse
@export var JSON_PATH: String

@export_category("VAT")
@export var VAT_axis_system: String
@export var VAT_bound_max: Vector3 : set = set_VAT_bound_max
@export var VAT_bound_min: Vector3 : set = set_VAT_bound_min
@export var VAT_houdini_fps: float : set = set_VAT_houdini_fps
@export var VAT_name: String
@export var VAT_two_position_textures: int

@export_category("Material")
@export var vat_material: Material


func set_pulse(value):
	load_vat(JSON_PATH)

func set_VAT_axis_system(value):
	VAT_axis_system = value

func set_VAT_bound_max(value):
	VAT_bound_max = value
	if vat_material: vat_material.set_shader_parameter("_boundMax", value)

func set_VAT_bound_min(value):
	VAT_bound_min = value
	if vat_material: vat_material.set_shader_parameter("_boundMin", value)

func set_VAT_houdini_fps(value):
	VAT_houdini_fps = value
	if vat_material: vat_material.set_shader_parameter("_houdiniFPS", value)

func set_VAT_name(value):
	VAT_name = value

func setup_vat(_JSON_PATH: String):
	var json = load(_JSON_PATH)
	var map = json.data[0]
	
	for key in map:
		var name: String = key 
		
		if name[-1] in ['X','Y','Z']:
			name[-2] = ':'
		
		name = "VAT_" + name.to_snake_case()
		set_indexed(name, map[key])

func load_vat(_JSON_PATH: String):
	if _JSON_PATH.is_empty():
		push_warning("File path empty")
		return
	
	if !vat_material:
		push_warning("Material must be set")
		return
	
	setup_vat(_JSON_PATH)


# Called when the node enters the scene tree for the first time.
func _ready():
	load_vat(JSON_PATH)
