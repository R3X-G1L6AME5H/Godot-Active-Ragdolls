extends RigidBody

"""
	Active Ragdolls - Ragdoll Bone
		by Nemo Czanderlitch/Nino Čandrlić
			@R3X-G1L       (godot assets store)
			R3X-G1L6AME5H  (github)

	This is the script which transfers the rotation from the RigidBody
	to the skeleton.
"""

export (String) var bone_name
var BONE_INDEX : int = -1

"""
	INIT
"""
func _ready() -> void:
	if Engine.editor_hint:
		set_physics_process(false)
	else:
		assert(get_parent() is Skeleton, "The Ragdoll Bone[%s] is supposed to be a child of a Skeleton" % [self.name])
		assert(bone_name != "", "The Ragdoll Bone[%s] needs to have its bone name defined" % [self.name])
		BONE_INDEX = get_parent().find_bone(bone_name)
		assert(BONE_INDEX >= 0, "The Ragdoll Bone's[%s] bone name[%s] does not match any bone in the skeleton" % [self.name, bone_name])


"""
	APPLY OWN ROTATION TO THE RESPECTIVE BONE IN PARENT SKELETON
"""
func _physics_process(_delta: float) -> void:
	var bone_global_rotation : Basis = get_parent().global_transform.basis * get_parent().get_bone_global_pose(BONE_INDEX).basis
	var b2t_rotation : Basis = bone_global_rotation.inverse() * self.transform.basis
	get_parent().set_bone_pose(BONE_INDEX, Transform(get_parent().get_bone_pose(BONE_INDEX).basis * b2t_rotation))
