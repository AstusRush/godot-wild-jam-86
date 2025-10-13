class_name Enemy
extends RigidBody2D

var _dead = false
signal EV_Dead

const DeadDampening = 5
const ImpactForceMod = 1.2
const CollisionMaskAlive = 4
const CollisionMaskDead = 4 # can now collide with walls

@export var turnSpeed : float = 50
@export var fieldOfView : float = 100
@export var viewRange : float = 700

@export var viewRotate : Node2D
var _lookingDir : Vector2

func _enter_tree():
	linear_damp=0
	collision_mask=CollisionMaskAlive # not colliding with anything
	testSpeed=100

var testSpeed : float

func _physics_process(delta):
	if isDead():
		return

	linear_velocity=Vector2.DOWN*testSpeed
	if linear_velocity!=Vector2.ZERO:
		_lookingDir=linear_velocity.normalized()
		viewRotate.rotation_degrees=MathS.VecToDeg(_lookingDir)+90
	# player detection
	if true: #TODO check if this enemy can even detect the player
		var dirToPlayer = position.direction_to(Level.player.position)
		var angleToPlayer : float = rad_to_deg(dirToPlayer.angle_to(_lookingDir))
		if abs(angleToPlayer)<=fieldOfView/2: # is the player within the field of view?
			var distToPlayer = position.distance_to(Level.player.position)
			if distToPlayer <= viewRange : # is the player close enough
				# are there no obstacles in the way
				var colMask = 4 # collision mask should only detect walls
				var query = PhysicsRayQueryParameters2D.create(position, Level.player.position,colMask)
				var spaceState = get_world_2d().direct_space_state
				var result : Dictionary = spaceState.intersect_ray(query)
				if result.is_empty(): # are there no walls blocking the view?
					detect()

func detect():
	pass


func hit(impactForce : Vector2):
	if not _dead:
		linear_velocity=impactForce*ImpactForceMod
		linear_damp=DeadDampening
		collision_mask=CollisionMaskDead
		_dead=true
		EV_Dead.emit(impactForce)
	else:
		pass

func isDead():
	return _dead
