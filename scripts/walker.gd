extends Node
class_name Walker

const DIRECTIONS := [ Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN ]

var pos := Vector2.ZERO
var dir := Vector2.RIGHT
var borders := Rect2()
var step_history := []
var steps_since_turn := 0

func _init(starting_pos : Vector2, new_borders : Rect2):
	assert(new_borders.has_point(starting_pos))
	pos = starting_pos
	step_history.append(pos)
	borders = new_borders

func walk(steps) -> Array:
	for _s in steps:
		if randf() <= 0.25 or steps_since_turn >= 1:
			change_direction()
		
		if step():
			step_history.append(pos)
		else:
			change_direction()
	return step_history

func step():
	var target_pos = pos + dir
	if borders.has_point(target_pos) or target_pos in step_history:
		steps_since_turn += 1
		pos = target_pos
		return true
	else:
		return false

func change_direction():
	steps_since_turn = 0
	var directions_copy = DIRECTIONS.duplicate()
	directions_copy.erase(dir)
	directions_copy.shuffle()
	dir = directions_copy.pop_front()
	while not borders.has_point(pos + dir):
		dir = directions_copy.pop_front()
	
