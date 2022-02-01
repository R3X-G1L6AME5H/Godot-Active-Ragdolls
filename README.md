# Active Rigid-Body Ragdoll
## In summary...
A Godot plugin for Ragdolls that uses `RigidBody`, and `Generic6DOFJoint` instead of `PhysicalBone`. This allows for much more options regarding Ragdolls. The Godot's default ragdolls that use `PhysicalBone`s are generally all you will need in your game, **however** if you are trying to implement something special like **Active Ragdolls**, you will find `PhysicalBone`s to be unsatisfactory.

## WARNING
* This plugin relies entirely on `Generic6DOFJoint` to work. These joints are difficult to configure without any prior knowledge, so be sure to experiment is separate scene before attempting to configure joints for some complex skeleton. 
	* Furthermore, to my knowledge, they work only for Bullet Physics Engine. Make sure to check `General/Physics/3d/Physics Engine` in your project settings is set to BULLET.
* Lastly, this plugin uses `RigidBody` instead of `PhysicalBone`. The reason you should care is because `PhysicalBone` simulation can be stopped; `RigidBody` cannot. As mentioned before, this plugin is for specific cases only. Cases where constant physics simulation is crucial. 

## Usage
Its quite simple. There are three relevant scripts. `CreateRagdoll.gd` is responsible for creating `RigidBody` bones, and joints for the skeleton. `RagdollBone.gd` applies the `RigidBody`s transform to its respectable bone in the parent `Skeleton`. Finally, `ActiveRagdollJoint.gd` connects RagdollBones together, and attempts to match it's rotation with the animated skeleton.

### CreateRagdoll.gd
This script goes on a `Skeleton` node. Treat tick boxes as buttons. They should always be unticked. If not, close your scene and open it again. Be careful because these actions cannot be undone with `Ctrl-z`. Overall, this script has 4 properties: 
* `Create Ragdoll` will create RigidBodies for all bones specified in the `Bone Whitelist` with their `ColisionShape`. **Renaming** anything created by this function will result in other functions **not working**... atleast until you manually change properties in relevant nodes. **Transforming** any of the created RigidBodies is **not reccomended**, and will result in unexpected behaviour. On the other, the **created CollisionShapes MUST be fitted to the body**. The CollisionShape may be any shape you like, but keep in mind how only `BoxShape` and `CapsuleShape` are supported by `Have Debug Meshes` function. Make sure to have a bit of **overlap** between neighbouring CollisionShapes, so that the joints work properly.  
* `Bone Whitelist` accepts ranges [*0-10,12-15* ], as well as individual menitions [*10,23,42*] of bone id's in Skeleton. **!!! There is no safe guard for overlaping ranges[*10-20,15-25*], duplicates[2,2,2-4], or unordered ranges[4-1,6-2] !!!**
* `Create Joints` will create joints that connect all the RigidBodies together. These are `Generic6DOFJoint` with an `ActiveRagdollJoint.gd` attached to it by default. 

Finally, there are two relevant methods in this script: `start_tracing()` and `stop_tracing()`. On runtime, this can make the ragdoll go between following an animation, and going fully limp.

### RagdollBone.gd
These are simply `RigidBone` nodes that that act as bones for the ragdoll. Their only purpose is to simulate physics, and apply their `Transform` to the relevant bone in its parent `Skeleton`. This node **MUST** be under a `Skeleton` node. It will do you good to assign some accurate weights to the RigidBodies for better simulations.
* `Bone Name` is the only property it holds. This is the name of the bone to which the node's transform is being applied to. It is set automatically by `Create Ragdoll` so it is rare that you will need to change it. 

### ActiveRagdollJoint.gd
`Generic6DOFJoint` can imitate any other type of joint, provided that you know how to configure them. Aditionally, it provides motors that can move the ragdoll bones using forces. Tapping into the powerful potential of these Joints is the entire reason for this plugin. 
* `Animation Skelton` is a `NodePath` to a `Skeleton` whose animations should be mirrored. This replicates the popular approach to Active Ragdolls, where one skeleton plays the animation without any physics simuations, and the other attempts to mirror it by applying forces to the joints. If you don't intend to mirror another skeleton, then you can detach this script from the joint.
	* The joints will not stop working without this script, neither will there be an impact on the Ragdoll as a whole. This means that you can implement your own joint scripts if you so wish.  
* `Bone A Index` and `Bone A Index` serve only as a refference for the bones in the `Animation Skeleton`. These id's should correspond to whichever bones correspond to bones in `Nodes/Node A` and `Nodes/Node B` respectively. If the the parent `Skeleton` and `Animation Skeleton` are duplicates, then these need not be touched. ONLY if you are attempting to remap the anmations from a foreign skeleton will you need to change this property. 
* `Matching Velocity` is simply the multiplier for the forces that attempt to match the current bone to the target rotation. You need to remember that the ragdoll is entirely animated by physics. If the arm is too heavy, the motor will have trouble matching its rotation to the target one. Hence, this property will need some tweaking and tuning.
