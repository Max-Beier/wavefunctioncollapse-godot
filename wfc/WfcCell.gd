@tool
class_name WfcCell
extends Node3D

var size: int
var collapsed: bool = false
var entropy: int = -1

var id: int
var connectors: Array = [[], [], [], [], [], []]

func set_entropy():
	self.entropy = self.connectors[0].size() + self.connectors[1].size() + self.connectors[2].size() + self.connectors[3].size() + self.connectors[4].size() + self.connectors[5].size()

func set_init_state(template: WfcCell):
	self.connectors = template.connectors.duplicate(true)
	self.entropy = template.entropy

func collapse(rng: RandomNumberGenerator, prototypes: Dictionary):
	var axis: Array = []
	var neighbor = null
	
	while (neighbor == null):
		axis = connectors[rng.randi() % connectors.size()]
		if !axis.is_empty():
			neighbor = axis[rng.randi() % axis.size()]
			self.id = neighbor
	
	var prototype: Dictionary = prototypes[str(self.id)]
	var child: Node3D = load(prototype.path).instantiate()
	self.add_child(child)
	self.collapsed = true
