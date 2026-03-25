extends Node2D
class_name Cell

var data : CellData

@export var road : Sprite2D
@export var destination_marker : Sprite2D
@export var destination_marker_ground : Sprite2D
@export var destination_marker_outline : Sprite2D
@export var destination_player : AnimationPlayer
@export var mode_switcher : PuzzleModeSwitcher

var road_textures : Dictionary[String, String] = {
	"XXXX": "",
	"OXXX": "tileGrass_roadDeadE.png",
	"XOXX": "tileGrass_roadDeadS.png",
	"XXOX": "tileGrass_roadDeadW.png",
	"XXXO": "tileGrass_roadDeadN.png",
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
	cd.changed.connect(refresh)
	refresh()

func refresh() -> void:
	# road texture
	var tex_id := get_cell_texture_id(data)
	var tex_path := road_textures[tex_id]
	if tex_path != "":
		road.texture = load("res://map/roads/sprites/" + tex_path)
	
	# car destination
	var type_destination := Cars.get_car_type(data.is_destination_for)
	mode_switcher.update(type_destination)
	print("DESTINATION TYPE | " + str(type_destination))
	var is_dest := data.is_destination()
	var dest_reached := data.has_been_reached()
	
	destination_marker.set_visible(is_dest)
	destination_marker_outline.set_visible(is_dest)
	destination_marker_ground.set_visible(is_dest)
	
	if dest_reached:
		destination_marker.modulate = Color.WHITE
	
	# ugh this transfer is needed to prevent the number/letter/shape modulating too
	destination_marker.self_modulate = destination_marker.modulate
	destination_marker.modulate = Color.WHITE
	
	if is_dest:
		var anim_key := "destination_disappear" if dest_reached else "destination_float"
		destination_player.speed_scale = randf_range(0.8, 1.2)
		destination_player.play(anim_key)
	else:
		destination_player.stop()

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
