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
	# Reset the rotations of all joints
	for joint in joints:
		joint.rotation = 0
	# Clear start offsets
	start_offsets.clear()
	# Loop through each joint and store the offset between joint's "bone" towards the NEXT joint.
	for i in range(joints.size() - 1):
		if joints[i+1]:
			start_offsets.append(joints[i+1].position)
	print("FK: positions initialised.")
	pass
	
func calculateFK(angles: Array) -> Vector2:
		# Start at the base
	var prev_position = joints[0].position # Get the root joint's position.
	var cumulative_angle = 0.0 # Start with no rotation (angle) stored.
	
	for i in range(start_offsets.size()):
		# Accumulate the rotation by multiplying the cumulative rotation by the current_rotation, (parent * child)
		cumulative_angle += deg_to_rad(angles[i])
		# Now, calculate the new position and rotation of the next joint.
		var direction = start_offsets[i].rotated(cumulative_angle)
		# Move the next joint to the new position calculated from above.
		var next_position = prev_position + direction
		# Snap back bone to original position if accidentally moved
		if i + 1 < joints.size():
			# If joints are nested, we force the child's local position back to the specific stored offset.
			joints[i+1].position = start_offsets[i]
		prev_position = next_position
	return prev_position - joints[0].position

func _trigger_init(_val):
	initPositions()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	queue_redraw() # Draw bones between the joints, is the code from the function _draw() above.
	
	if joints.size() < 2: return # If chain too small... return.
	
	# Create empty array to hold current joint angles from the editor.
	var current_angles = []
	
	# Fill array with current rotation of each joint.
	for joint in joints:
		current_angles.append(joint.rotation_degrees)
	
# Change tracking and print changes made to position and rotation
	if last_angles.size() != current_angles.size():
		last_angles = current_angles.duplicate()
	
	for i in range(current_angles.size()):
		if abs(current_angles[i] - last_angles[i]) > 0.01:
			print("Joint ", i, " rotated! New Angle: ", current_angles[i])
			last_angles = current_angles.duplicate()

	# The resulting fk_position will have both X and Y components
	var fk_position = calculateFK(current_angles)
