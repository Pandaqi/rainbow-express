extends Line2D
class_name RouteDrawer

var car : Car

func attach_to_car(c:Car) -> void:
	car = c

func _process(_dt:float) -> void:
	if car.is_moving():
		refresh()

func refresh() -> void:
	var color := Rainbow.get_color_for_type(Cars.get_car_type(car.index))
	default_color = color

	var positions : PackedVector2Array = []
	var num_positions := car.route.size()
	for i in range(num_positions):
		var pos := car.route[i].global_position
		var is_last_pos := i == (num_positions - 1)
		if is_last_pos: pos = car.global_position
		positions.append(pos)
	
	if positions.size() < 2: return
	points = convert_to_spline(positions)

func convert_to_spline(_pts: PackedVector2Array, resolution := 10, extrapolate_end_points := true) -> PackedVector2Array:
	var pts:PackedVector2Array = _pts.duplicate()
	if extrapolate_end_points:
		pts.insert(0, pts[0] - (pts[1] - pts[0]))
		pts.append(pts[-1] + (pts[-1] - pts[-2]))

	var smooth_points := PackedVector2Array()
	if pts.size() < 4: return pts

	for i in range(1, pts.size() - 2):
		var p0 := pts[i - 1]
		var p1 := pts[i]
		var p2 := pts[i + 1]
		var p3 := pts[i + 2]

		for t in range(0, resolution):
			var tt := t / float(resolution)
			var tt2 := tt * tt
			var tt3 := tt2 * tt
			var q := (
				0.5
				* (
					(2.0 * p1)
					+ (-p0 + p2) * tt
					+ (2.0 * p0 - 5.0 * p1 + 4 * p2 - p3) * tt2
					+ (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * tt3
				)
			)
			smooth_points.append(q)
	
	return smooth_points
