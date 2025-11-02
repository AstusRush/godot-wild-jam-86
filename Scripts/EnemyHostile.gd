#for guard and dog
class_name EnemyHostile
extends Enemy

@export var speedPatrol : float = 400
@export var speedAlarmed : float = 500
@export var speedChaseStart : float = 700
@export var speedChaseEnd : float = 700
@export var chaseDecayDur : float = 3
@export var chaseEndDur : float = 1

@export var attackHitbox : Area2D
@export var targetDistanceToPlayer : float #shouldn't be stuck inside player
@export var swingWeaponEffect : PackedScene

var _chaseT : float
var _timeSinceLos : float

var patrolTarget : Vector2
signal EV_ChaseStart
signal EV_ChaseEnd


@export var maxWaitDuration : float = 4
var waitDuration : float
var curWaitT : float


enum HosState{Patrol, Alarmed, Wait, Chase}
var curState : HosState

func _enter_tree():
	super._enter_tree()
	choosePatrolPoint()
	attackHitbox.body_entered.connect(_onAttackHitboxBodyEntered)
	attackHitbox.body_exited.connect(_onAttackHitboxBodyExited)

func alarm():
	if isDead():
		return
	if curState == HosState.Chase:
		return
	curState=HosState.Alarmed
	speed=speedAlarmed
	nav.target_position=Level.player.position

func discoverPlayer():
	chase()
	

func chase():
	if type==Level.EnemyType.Guard:
		var guardIdx = randi_range(0,0)
		SoundSpawner.SpawnFromName("GuardGrunt"+str(guardIdx))
	elif type==Level.EnemyType.Dog:
		SoundSpawner.SpawnFromName("DogBark")

	lethal=true
	disablePerception()
	curState=HosState.Chase
	_chaseT=0
	speed=speedChaseStart
	EV_ChaseStart.emit()

func discoverCorpse(corpse : Enemy):
	corpse.bodyFound()

func choosePatrolPoint():
	lethal=false
	enablePerception()
	curState=HosState.Patrol
	patrolTarget=MathS.RandVec2()*2040
	nav.target_position=patrolTarget
	speed=speedPatrol



func wait():
	lethal=false
	enablePerception()
	curState=HosState.Wait
	waitDuration=maxWaitDuration*max(0.2,randf())*maxWaitDuration
	curWaitT=0
	speed=0


var playerInside : bool = false
func _onAttackHitboxBodyEntered(body : Node):
	if body != Level.player:
		return
	playerInside=true

func _onAttackHitboxBodyExited(body : Node):
	playerInside=false


func instantDetectCheck():
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
				chase()
				if Level.player.getEquippedMask()!=null:
					var en = Level.player.getEquippedMask().enemy
					if en != null:
						en.bodyFound()

func spawnSwingEffect():
	var swing : FadeSprite = swingWeaponEffect.instantiate()
	swing.position=Level.player.position.lerp(position,0.5)
	swing.rotation_degrees=MathS.VecToDeg(position.direction_to(Level.player.position))+90
	Level.player.get_parent().add_child(swing)

func _physics_process(delta):
	super._physics_process(delta)
	if playerInside and not Level.player.isInvincible() and lethal and not isDead():
		Level.player.damage(-position.direction_to(Level.player.position))
		spawnSwingEffect()


	match curState:
		HosState.Patrol:
			if nav.is_navigation_finished():
				wait()
		HosState.Alarmed:
			if nav.is_navigation_finished():
				choosePatrolPoint()
		HosState.Wait:
			curWaitT+=delta
			if curWaitT>waitDuration:
				choosePatrolPoint()
		HosState.Chase:
			nav.target_position=Level.player.position
			var playerLineOfSight : bool = false
			var colMask = 4 # collision mask should only detectPlayerStep walls
			var query = PhysicsRayQueryParameters2D.create(position, Level.player.position,colMask)
			var spaceState = get_world_2d().direct_space_state
			var result : Dictionary = spaceState.intersect_ray(query)
			if result.is_empty(): # are there no walls blocking the view?
				playerLineOfSight=true
			
			
			var distToPlayer = position.distance_to(Level.player.position)
			if playerLineOfSight or distToPlayer < targetDistanceToPlayer*1.2:
				_timeSinceLos=0
			else:
				_timeSinceLos+=delta
			_chaseT+=delta

			if distToPlayer < targetDistanceToPlayer:
				speed=0
			else:
				speed = lerp(speedChaseStart, speedChaseEnd,min(_chaseT/chaseDecayDur,1))
			if _timeSinceLos >= chaseEndDur:
				wait()
				EV_ChaseEnd.emit()
			if Level.player.isDead():
				wait()


func hit(impactForce : Vector2):
	if not _dead:
		if lethal and not Level.player.isInvincible():
			Level.player.damage(-impactForce)
			spawnSwingEffect()
	super.hit(impactForce)
