tool
extends EditorProperty

const FileManager = preload("res://addons/cartographer/terrain/carto_terrain_material_editor/file_manager.gd")
const LayersList = preload("res://addons/cartographer/terrain/carto_terrain_material_editor/layers_list.gd")
var prop_box: VBoxContainer
var file_manager: FileManager
var layers_list: LayersList
var edited_obj
var edfs

func _init():
	prop_box = VBoxContainer.new()
	prop_box.add_constant_override("separation", 4)
	file_manager = FileManager.new()
	file_manager.connect("created", self, "_on_created")
	file_manager.connect("loaded", self, "_on_loaded")
	layers_list = LayersList.new()
	layers_list.connect("property_set_value", self, "emit_changed")
	
	prop_box.add_child(file_manager)
	prop_box.add_child(layers_list)

func _ready():
	edited_obj = get_edited_object()
	edfs = Cartographer.editor.get_resource_filesystem()
	add_child(prop_box)
	set_bottom_editor(prop_box)

func _on_created(path):
	edfs.connect("resources_reimported", self, "_on_loaded", [], CONNECT_ONESHOT)
	edfs.scan()

func _on_loaded(path):
	path = path[0] if path is PoolStringArray else path
	var res = load(path)
	if not res is TextureArray:
		return ERR_INVALID_DATA
	
	emit_changed("textures", res)

func update_property():
	layers_list.bind(edited_obj)
