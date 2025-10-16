class_name Enemy
extends RigidBody2D

var _dead = false
signal EV_Dead

const DeadDampening = 5
const ImpactForceMod = 1.2
const CollisionMaskAlive = 0
const CollisionMaskDead = 0 # can now collide with walls

@export var type : Level.EnemyType
@export var turnSpeed : float = 50
@export var fieldOfView : float = 100
@export var viewRange : float = 700

@export var viewRotate : Node2D
var _lookingDir : Vector2

@export var corpseDespawnTime : float = 20
var corpseT : float = 0
const corpseFadeThreshold : float = 0.65


@export var nav : NavigationAgent2D

func _enter_tree():
	linear_damp=0
	collision_mask=CollisionMaskAlive # not colliding with anything
	testSpeed=300

var testSpeed : float

func _process(delta: float):
	navigateTowards(Level.player.position)

func _physics_process(delta):
	if isDead():
		corpseT+=delta
		if corpseT >= corpseDespawnTime:
			queue_free()
		elif corpseT >= corpseDespawnTime-corpseFadeThreshold:
			discoverCorpse()
			modulate.a=(corpseDespawnTime-corpseT)/corpseFadeThreshold
		return

	if linear_velocity!=Vector2.ZERO:
		_lookingDir=linear_velocity.normalized()
		viewRotate.rotation_degrees=MathS.VecToDeg(_lookingDir)+90
	# player detection
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
				detect(delta, distToPlayer)

	if not nav.is_target_reached():
		var navDir : Vector2 = global_position.direction_to(nav.get_next_path_position())
		linear_velocity=navDir*testSpeed

func detect(delta, distToPlayer):
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

var _discovered : bool = false
func discoverCorpse():
	if not isDead() or _discovered:
		return
	_discovered=true
	EV_DiscoverCorpse.emit()
	if corpseDespawnTime - corpseFadeThreshold > corpseT:
		corpseT = corpseDespawnTime - corpseFadeThreshold

signal EV_DiscoverCorpse

func navigateTowards(pos : Vector2):
	nav.target_position=pos
