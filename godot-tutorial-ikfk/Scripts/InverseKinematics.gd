@tool
extends Node2D
@export var joints: Array[Node2D]
@export var target: Node2D
var stored_positions: Array[Vector2]
var lengths: Array[float]

@export var update_lengths: bool = false:
	set(val):
		# When this checkbox is enabled in the inspector, it recalculates lengths + resets positions + stored positions
		if target:
			target.global_position = Vector2(0, -600)
		setupIK()

func _draw() -> void:
	# This method is already here, it is used to draw some bones between the joints for visualisation purposes!
	if joints.size() < 2: return
	
	for i in range(joints.size() - 1): # This draws the bones.
		if joints[i] and joints[i+1]:
			var start = to_local(joints[i].global_position)
			var end = to_local(joints[i+1].global_position)
			draw_line(start, end, Color.CYAN, 10)
	
	for joint in joints: # This draws the orientation lines of the bones.
		if not joint: continue
		var start = to_local(joint.global_position)
		var right_dir = joint.global_transform.x * 2.0
		var right_end = to_local(joint.global_position + right_dir)
		var top_dir = -joint.global_transform.y * 2.0
		var top_end = to_local(joint.global_position + top_dir)
		draw_line(start, right_end, Color.RED, 3.5)   # Red for (X)
		draw_line(start, top_end, Color.BLUE, 3.5)  # Blue for (Y)

func FABRIK() -> void:
	# !!! TBD in this tutorial !!!
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupIK()

func setupIK() -> void:
	# !!! TBD in this tutorial !!!
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw() # visualise bones.
	FABRIK() # Run IK.
