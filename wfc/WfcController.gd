@tool
class_name WfcController
extends Node

@export_category("Settings")
@export var seed := 0
@export var plot_size := 50
@export var grid_size := 2

var rng := RandomNumberGenerator.new()
var uncollapsed = true

var init_cell_template: WfcCell = WfcCell.new()
var prototypes: Dictionary = {}
var cells: Dictionary = {}
var cell_buffer: Array[WfcCell]  = []

func _ready():
	rng.seed = seed
	load_prototypes()
	_generate()

func _generate():
	# Add new cells
	for x in range(-plot_size * 0.5, plot_size * 0.5, grid_size):
		for z in range(-plot_size * 0.5, plot_size * 0.5, grid_size):
			for y in range(-plot_size * 0.5, plot_size * 0.5, grid_size):
				var position := Vector3.ZERO
				if !cells.has(position):
					var cell: WfcCell = cell_buffer.pop_back() if cell_buffer.size() > 0 else WfcCell.new()
					cell.set_init_state(init_cell_template)
					cell.position = position
					cells[position] = cell
					add_child(cell)
		
	# Collapse random cell with random prototype
	var cell_key: Vector3 = Vector3(1.0, 0.0, 1.0) * cells.keys()[(rng.randi() % cells.size())]
	var c_cell: WfcCell = cells[cell_key]
	c_cell.collapse(rng, prototypes)
	
	# WFC
	while uncollapsed:
		# Get min entropy
		c_cell = null
		for position in cells:
			var cell: WfcCell = cells[position]
			if !cell.collapsed && (c_cell == null || c_cell.entropy > cell.entropy):
				c_cell = cell
		
		# If no cell is uncollapsed, then we can't collapse anything
		if !c_cell:
			uncollapsed = false
			return
		
		# Collapse the cell with the min entropy
		c_cell.collapse(rng, prototypes)
		
		# Propagate
		var stack = []
		stack.append(c_cell)
		
		while stack.size() > 0:
			c_cell = stack.pop_back()
			
			# TODO
			#for d in c_cell.valid_directions():
			#	pass
		
		# Check if all have been collapsed for next interation
		var not_all_collapsed = false
		for c_key in cells:
			if !cells[c_key].collapsed:
				not_all_collapsed = true
				break
		
		if !not_all_collapsed:
			uncollapsed = false

func load_prototypes():
	var file := FileAccess.open("res://wfc/prototypes.json", FileAccess.READ)
	prototypes = JSON.parse_string(file.get_as_text())
	file.close()
	
	for p_key in prototypes:
		var prototype: Dictionary = prototypes[str(p_key)]
		init_cell_template.connectors[0].append_array(prototype.connectors[0])
		init_cell_template.connectors[1].append_array(prototype.connectors[1])
		init_cell_template.connectors[2].append_array(prototype.connectors[2])
		init_cell_template.connectors[3].append_array(prototype.connectors[3])
		init_cell_template.connectors[4].append_array(prototype.connectors[4])
		init_cell_template.connectors[5].append_array(prototype.connectors[5])
		init_cell_template.set_entropy()
