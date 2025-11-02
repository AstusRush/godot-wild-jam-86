class_name Enemy
extends RigidBody2D

var _dead = false
signal EV_Dead

const DeadDampening = 5
const ImpactForceMod = 1.2
const CollisionMaskAlive = 0
const CollisionMaskDead = 4 # can now collide with walls

@export var type : Level.EnemyType
@export var fieldOfView : float = 100
@export var viewRange : float = 700

@export var seeThroughMask : bool

@export var viewRotate : Node2D
var _lookingDir : Vector2

@export var corpseIdentifyTime : float = 20
var corpseT : float = 0

var curPerception : float = 0
@export var perceptiveness : float = 2
@export var perceptionDecay : float = 0.5
@export var viewCone : ViewCone
var lethal : bool = false


@export var nav : NavigationAgent2D
var speed : float = 0

func _enter_tree():
	linear_damp=0
	collision_mask=CollisionMaskAlive # not colliding with anything

func _ready():
	viewCone.setup(fieldOfView,viewRange,self)
	enablePerception()


var percieving : bool
func disablePerception():
	percieving=false
	viewCone.visible=false
func enablePerception():
	if isDead():
		return
	percieving=true
	curPerception=0
	viewCone.visible=true

func _physics_process(delta):
	if isDead():
		corpseT+=delta
		if not discovered:
			if corpseT >= corpseIdentifyTime:
				bodyFound()
				corpseT=0
		else:
			modulate.a=1-(corpseT/0.5)
			if corpseT >= 0.5:
				remove()
			
		return

	if linear_velocity!=Vector2.ZERO:
		_lookingDir=linear_velocity.normalized()
		viewRotate.rotation_degrees=MathS.VecToDeg(_lookingDir)+90
	
	# player detection
	var detectStepExecuted : bool = false
	

	if not Level.player.isDead():
		if not Level.player.isDisguised() or seeThroughMask: #is the enemy fooled by the players appearance?
			var dirToPlayer = position.direction_to(Level.player.position)
			var angleToPlayer : float = rad_to_deg(dirToPlayer.angle_to(_lookingDir))
			if abs(angleToPlayer)<=fieldOfView/2: # is the player within the field of view?
				var distToPlayer = position.distance_to(Level.player.position)
				if distToPlayer <= viewRange : # is the player close enough
					# are there no obstacles in the way
					var colMask = 4 # collision mask should only detectPlayerStep walls
					var query = PhysicsRayQueryParameters2D.create(position, Level.player.position,colMask)
					var spaceState = get_world_2d().direct_space_state
					var result : Dictionary = spaceState.intersect_ray(query)
					if result.is_empty(): # are there no walls blocking the view?
						detectStepExecuted=true
						detectPlayerStep(delta, distToPlayer)
			if not detectStepExecuted:
				curPerception=max(curPerception-perceptionDecay*delta,0)
		viewCone.perceptionUpdate(curPerception)

	# corpse detection
	var corpses : Array[Enemy]=Level.getEnemiesDead()
	for c in corpses:
		if not c.discovered:
			var dirToCorpse = position.direction_to(c.position)
			var angleToCorpse : float = rad_to_deg(dirToCorpse.angle_to(_lookingDir))
			if abs(angleToCorpse)<=fieldOfView/2: # is the corpse within the field of view?
				var distToCorpse = position.distance_to(c.position)
				if distToCorpse <= viewRange: # is the corpse close enough?
					# are there no obstacles in the way
					var colMask = 4 # collision mask should only detectPlayerStep walls
					var query = PhysicsRayQueryParameters2D.create(position, c.position,colMask)
					var spaceState = get_world_2d().direct_space_state
					var result : Dictionary = spaceState.intersect_ray(query)
					if result.is_empty(): # are there no walls blocking the view?
						discoverCorpse(c)

	if not nav.is_target_reached():
		var navDir : Vector2 = global_position.direction_to(nav.get_next_path_position())
		linear_velocity=navDir*speed
	else:
		linear_velocity=Vector2.ZERO

func detectPlayerStep(delta, distToPlayer):
	if not percieving:
		return
	
	if curPerception==0:
		SoundSpawner.SpawnFromName("DetectionStart",0.1)
	
	if curPerception >= 1:
		return
	curPerception+=delta*perceptiveness
	if curPerception >= 1:
		curPerception=1
		discoverPlayer()

func discoverPlayer():
	pass
func discoverCorpse(corpse : Enemy):
	pass

func hit(impactForce : Vector2):
	if not _dead:
		linear_velocity=impactForce*ImpactForceMod
		linear_damp=DeadDampening
		collision_mask=CollisionMaskDead
		_dead=true
		EV_Dead.emit(impactForce)
		Level.spawner.updateCounts()
	else:
		pass
		

func isDead():
	return _dead

var discovered : bool = false
func bodyFound():
	if not isDead() or discovered:
		return
	corpseT=0
	discovered=true
	EV_DiscoverCorpse.emit()

signal EV_DiscoverCorpse


func remove():
	Level.enemies.erase(self)
	queue_free()
	Level.spawner.updateCounts()
