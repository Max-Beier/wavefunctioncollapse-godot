@tool
extends Node3D

var prototypes_blueprints: Dictionary = {}
var all_prototypes_blueprints: Dictionary = {}

@export_category("Settings")
@export var build: bool = false:
	set(value):
		build = true
		_build()
		build = false

func _build():
	var id := 0
	prototypes_blueprints = {}
	all_prototypes_blueprints = {}
	var paths: Array[String] = []
	
	for obj in get_children():
		if not obj is WfcPrototype:
			printerr("Child of Prototype Builder must be: 'WfcPrototype'")
			return
		
		# Cache all nodes to identify as potential neighbors
		all_prototypes_blueprints[obj.position] = {
			"id": -1,
			"path": obj.scene_file_path
		}
		
		var prototype_blueprint: Dictionary = {
			"id": id,
			"connectors": [[], [], [], [], [], []],
			"size": obj.size,
			"node": obj,
			"path": obj.scene_file_path
		}
		
		if !paths.has(prototype_blueprint.path):
			prototypes_blueprints[prototype_blueprint.node.position] = prototype_blueprint
			paths.push_back(prototype_blueprint.path)
			id += 1
	
	# Give all children an id to identify as neighbor
	for k in prototypes_blueprints:
		for k_cpy in all_prototypes_blueprints:
			if (prototypes_blueprints[k].path == all_prototypes_blueprints[k_cpy].path):
				all_prototypes_blueprints[k_cpy].id = prototypes_blueprints[k].id
	
	var prototypes: Dictionary = {}
	for position in prototypes_blueprints:
		var prototype_blueprint: Dictionary = prototypes_blueprints[position]
		set_neighbors(prototype_blueprint)
		prototypes[prototype_blueprint.id] = {
			"id": prototype_blueprint.id,
			"connectors": prototype_blueprint.connectors,
			"path": prototype_blueprint.path
		}
	
	var file = FileAccess.open("res://wfc/prototypes.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(prototypes))
	file.close()

func set_neighbors(prototype_blueprint: Dictionary):
	var prototype_size: int = prototype_blueprint.node.size
	
	var xPVector = Vector3(prototype_blueprint.node.position.x + prototype_size, prototype_blueprint.node.position.y, prototype_blueprint.node.position.z)
	if all_prototypes_blueprints.has(xPVector):
		prototype_blueprint.connectors[0].push_back(all_prototypes_blueprints.get(xPVector).id)
	
	var xNVector = Vector3(prototype_blueprint.node.position.x - prototype_size, prototype_blueprint.node.position.y, prototype_blueprint.node.position.z)
	if all_prototypes_blueprints.has(xNVector):
		prototype_blueprint.connectors[1].push_back(all_prototypes_blueprints.get(xNVector).id)
	
	var yPVector = Vector3(prototype_blueprint.node.position.x, prototype_blueprint.node.position.y + prototype_size, prototype_blueprint.node.position.z)
	if all_prototypes_blueprints.has(yPVector):
		prototype_blueprint.connectors[2].push_back(all_prototypes_blueprints.get(yPVector).id)
	
	var yNVector = Vector3(prototype_blueprint.node.position.x, prototype_blueprint.node.position.y - prototype_size, prototype_blueprint.node.position.z)
	if all_prototypes_blueprints.has(yNVector):
		prototype_blueprint.connectors[3].push_back(all_prototypes_blueprints.get(yNVector).id)
	
	var zPVector = Vector3(prototype_blueprint.node.position.x, prototype_blueprint.node.position.y, prototype_blueprint.node.position.z + prototype_size)
	if all_prototypes_blueprints.has(zPVector):
		prototype_blueprint.connectors[4].push_back(all_prototypes_blueprints.get(zPVector).id)
	
	var zNVector = Vector3(prototype_blueprint.node.position.x, prototype_blueprint.node.position.y, prototype_blueprint.node.position.z - prototype_size)
	if all_prototypes_blueprints.has(zNVector):
		prototype_blueprint.connectors[5].push_back(all_prototypes_blueprints.get(zNVector).id)
