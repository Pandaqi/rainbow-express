extends Node2D
class_name Cell

var data : CellData

@export var road : Sprite2D
@export var overlay : Sprite2D

@export var collectible_scene : PackedScene

var road_textures : Dictionary[String, String] = {
	"XXXX": "tileGrass1.png",
	"OXXX": "tileGrass2.png", # @TODO: make proper single-connections
	"XOXX": "tileGrass2.png",
	"XXOX": "tileGrass2.png",
	"XXXO": "tileGrass2.png",
	"XOOX": "tileGrass_roadCornerLL.png",
	"OOXX": "tileGrass_roadCornerLR.png",
	"XXOO": "tileGrass_roadCornerUL.png",
	"OXXO": "tileGrass_roadCornerUR.png",
	"OXOX": "tileGrass_roadEast.png",
	"XOXO": "tileGrass_roadNorth.png",
	"OOXO": "tileGrass_roadSplitE.png",
	"OXOO": "tileGrass_roadSplitN.png",
	"OOOX": "tileGrass_roadSplitS.png",
	"XOOO": "tileGrass_roadSplitW.png",
	"OOOO": "tileGrass_roadCrossing.png"
}

func sync_data(cd:CellData) -> void:
	data = cd
	refresh()

func refresh() -> void:
	# road texture
	var tex_id := get_cell_texture_id(data)
	road.texture = load("res://map/roads/sprites/" + road_textures[tex_id])
	
	# truck start/end
	overlay.set_visible(data.is_start() or data.is_destination())
	overlay.modulate = PuzzleVisualizer.get_truck_color(data.get_truck_index())
	
	# display connections; cells are responsible for the connection to their right or down
	# (to prevent two cells both drawing the same connection)
	for connected_cell in data.connection_cells:
		var connection := data.connection_cells[connected_cell]
		if not connection.has_pickup(): continue
		
		var dir := connected_cell.pos - data.pos
		var is_right_or_down := dir.x > 0 or dir.y > 0
		if not is_right_or_down: continue
		
		var col : Collectible = collectible_scene.instantiate()
		col.sync_data(connection)
		col.set_position(dir * 32.0)
		add_child(col)

func get_cell_neighbor_index(cell:CellData, nb:CellData) -> int:
	var dir := nb.pos - cell.pos
	if dir.x > 0: return 0
	if dir.x < 0: return 2
	if dir.y > 0: return 1
	return 3

func get_cell_texture_id(cell:CellData) -> String:
	var states := ["X", "X", "X", "X"]
	for connection in cell.connections:
		states[get_cell_neighbor_index(cell, connection.get_other(cell))] = "O"
	return "".join(states)
