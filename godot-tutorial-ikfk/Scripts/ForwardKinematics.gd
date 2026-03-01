@tool # @Tool allows us to run this script in the editor.
extends Node2D

# Variables
@export var joints: Array[Node2D] = []: # Joints from the scene.
	set(value):
		joints = value
		queue_redraw() # Redraw our bones between the joints if new joints added to the scene.
var start_offsets: PackedVector2Array = [] # Joint positions.
@export var update_offsets: bool = false : set = _trigger_init # Button to reset bone lengths
var last_angles: Array = []

func _draw() -> void:
	# This method is already here, it is used to draw some bones between the joints for visualisation purposes!
	if joints.size() < 2: return
	
	for i in range(joints.size() - 1): # This draws the bones.
		if joints[i] and joints[i+1]:
			var start = to_local(joints[i].global_position)
			var end = to_local(joints[i+1].global_position)
			draw_line(start, end, Color.YELLOW, 10)
	
	for joint in joints: # This draws the orientation lines of the bones.
		if not joint: continue
		var start = to_local(joint.global_position)
		var right_dir = joint.global_transform.x * 2.0
		var right_end = to_local(joint.global_position + right_dir)
		var top_dir = -joint.global_transform.y * 2.0
		var top_end = to_local(joint.global_position + top_dir)
		draw_line(start, right_end, Color.RED, 3.5)   # Red for (X)
		draw_line(start, top_end, Color.BLUE, 3.5)  # Blue for (Y)

func draw_pos(node: Node2D) -> Vector2:
	return to_local(node.global_position)
	
func initPositions() -> void:
	# !!! TBD in this tutorial !!!
	pass
	
#func calculateFK(angles: Array) -> Vector2:
	# !!! TBD in this tutorial !!!
#	pass

func _trigger_init(_val):
	initPositions()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw() # Draw bones between the joints, is the code from the function _draw() above.
	
	# !!! TBD in this tutorial !!!
	
	pass
