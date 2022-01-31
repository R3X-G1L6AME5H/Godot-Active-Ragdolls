extends Generic6DOFJoint

export (NodePath) var animation_skeleton
var TARGET_SKELETON : Skeleton
export (int) var BONE_A_INDEX : int = -1
export (int) var BONE_B_INDEX : int = -1
export(float) var matching_velocity_multiplier = 1  ## HOW FAST, AND WITH WHICH FORCE THE JOINT MOTOR TRIES TO SNAP INTO POSITION



func _ready() -> void:
	if not Engine.editor_hint:
		### BLINDLY FOLLOWING THE THE CODE FOR THIS EXTENSION
		## https://gist.github.com/mstevenson/7b85893e8caf5ca034e6 ...AT LINE 66
		## COULD BE SPARADIC MOVEMENT IN RAGDOLL  
		#self.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
		#self.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
		#self.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_FORCE_LIMIT, 9999999)
		
		self.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
		self.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
		self.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_FORCE_LIMIT, 9999999)
		assert(self.get_parent() is Skeleton, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton" % [self.name])
		
		
		TARGET_SKELETON = self.get_node_or_null(animation_skeleton)
		if TARGET_SKELETON:  ### IF ANIMATED SKELETON EXISTS
			trace_skeleton(true)
		else:
			trace_skeleton(false)
		
		if BONE_A_INDEX < 0:
			assert(self.get_node(self.get("nodes/node_a")) is self.get_parent().RAGDOLL_BONE, "A RAGDOLL JOINT should have RAGDOLL BONE as node_a")
			BONE_A_INDEX = self.get_node(self.get("nodes/node_a")).BONE_INDEX
		
		if BONE_B_INDEX < 0:
			assert(self.get_node(self.get("nodes/node_b")) is self.get_parent().RAGDOLL_BONE, "A RAGDOLL JOINT should have RAGDOLL BONE as node_a")
			BONE_B_INDEX = self.get_node(self.get("nodes/node_b")).BONE_INDEX


"""
ENABLE/DISABLE ANIMATED SKELETON TRACING
"""
func trace_skeleton( value : bool ) -> void:
	self.set_physics_process(value)
	_declare_flag_for_all_axis( Generic6DOFJoint.FLAG_ENABLE_ANGULAR_LIMIT, not value )
	_declare_flag_for_all_axis( Generic6DOFJoint.FLAG_ENABLE_MOTOR, value )


"""
APPLY FORCES TO THE JOINTS TO MAKE THEM MATCH THE ANIMATED SKELETON
"""
func _physics_process(delta: float) -> void:
	if not Engine.editor_hint:
		var target_rotation : Basis = TARGET_SKELETON.get_bone_global_pose(BONE_B_INDEX).basis.inverse() * self.get_parent().get_bone_global_pose(BONE_B_INDEX).basis
		
		var target_velocity : Vector3 = target_rotation.get_euler() * matching_velocity_multiplier
		self.set_param_x(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, target_velocity.x)
		self.set_param_y(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, target_velocity.y)
		self.set_param_z(Generic6DOFJoint.PARAM_ANGULAR_MOTOR_TARGET_VELOCITY, target_velocity.z)


######################################
func _declare_flag_for_all_axis( param : int, value : bool ) -> void:
	self.set_flag_x(param, value)
	self.set_flag_y(param, value)
	self.set_flag_z(param, value)
