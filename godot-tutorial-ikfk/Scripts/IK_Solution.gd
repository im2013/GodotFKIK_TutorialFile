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
	# If no target is given, do not run!
	if not target:
		return
		
	# First store each initial position of each joint so we can set positions later. (Gives more accurate positions).
	# This is where we can update and store our maths before finishing our iterations, after which, we set our actual joint positions as this stored_positions.
	for i in range(joints.size()):
		stored_positions[i] = joints[i].global_position
	
	# Store root position.
	var base_position = stored_positions[0]
	
	# Add iterations to make the maths more accurate.
	for iteration in range(10):
		# BACKWARDS PASS: this affects end-effector to root.
		
		# Make the end effector (end joint) follow the target.
		stored_positions[joints.size() - 1] = target.global_position
		
		# Get the number of joints- REVERSED, for our backwards iteration.
		var indices = range(joints.size() - 1)
		indices.reverse()
		
		# Then, for each of the previous joints, in REVERSE, from the end-effector to the root.
		for i in indices:
			# Find the vector between point i+1 and point i by ding: joint i - joint + i.
			var vector = stored_positions[i] - stored_positions[i + 1]
			# Find the direction the vector is going by Normalizing it.
			var dir = vector.normalized()
			# Snap the PREVIOUS joint's position relative to the next joint's position.
			stored_positions[i] = stored_positions[i + 1] + (dir * lengths[i])
		
		# FORWARDS PASS: # This affects from root-to-end effector.
		# First pin the root bone to its original stored position.
		stored_positions[0] = base_position
		
		# Iterate FORWARDS this time from i till i - 1 (second last joint).
		for i in range(joints.size() - 1):
			# Calculate vector pointing from joint [i] to the next joint [i+1].
			var vector = stored_positions[i + 1] - stored_positions[i]
			# Normalise the vector to get the direction
			var dir = vector.normalized()
			# Snap the NEXT joint's position relative to the previous joint's position.
			stored_positions[i + 1] = stored_positions[i] + (dir * lengths[i])
	
	# Finally, set the actual joint positions as the stored positions we calculated above.
	for i in range(joints.size()):
		joints[i].global_position = stored_positions[i]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setupIK()

func setupIK() -> void:
	if joints.size() < 2: return
	
	if target:
		target.global_position = Vector2(0, -600)
	
	stored_positions.resize(joints.size()) # Make stored positions same size as joints.
	
	lengths.resize(joints.size() - 1)
	
	# Calculate and store the bone lengths between each joint, it is i-1 for e.g. 3 joints means 2 bones.
	for i in range(joints.size() - 1):
		var dist = joints[i].global_position.distance_to(joints[i+1].global_position)
		lengths[i] = dist

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw() # visualise bones.
	FABRIK() # Run IK.
