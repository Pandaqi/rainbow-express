extends Node2D
class_name CarParticles

@export var particles : CPUParticles2D
@export var anchors : Array[Node2D]

func set_active(ac:bool) -> void:
	particles.set_visible(ac)
	particles.emitting = ac

func update_from_car_frame(frm:int) -> void:
	var pos := anchors[frm].position
	particles.set_position(pos)
	
	# move above car if looking at back, otherwise behind car
	z_index = 16 if (frm == 3) else 0
