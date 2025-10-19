class_name EnemyCivilian
extends Enemy

var identity : HumanIdentity

func _enter_tree():
	super._enter_tree()
	identity = HumanIdentity.new(get_parent())
	chooseWanderPoint()


var wanderTarget : Vector2
var doorTarget : Door

enum CivState{Wander, Wait, Panic}
var curState : CivState
@export var speedWander : float = 200
@export var speedPanic : float = 200
@export var maxWaitDuration : float = 4
var waitDuration : float
var curWaitT : float

var discoverList : Array[Enemy]


#alerts all hostile enemies to the players position
func scream():
	var screamIdx = 0
	SoundSpawner.SpawnFromName("PanicScream"+str(screamIdx),0.1)
	var hostiles : Array[Enemy] = Level.getEnemiesHostile()
	for h : EnemyHostile in hostiles:
		h.alarm()
	ParticleSpawner.SpawnFromName("Soundwave",position)




func discoverPlayer():
	panic()
	scream()
func discoverCorpse(corpse : Enemy):
	if discoverList.has(corpse):
		return
	panic()
	discoverList.append(corpse)


func chooseWanderPoint():
	curState=CivState.Wander
	wanderTarget=MathS.RandVec2()*2040
	nav.target_position=wanderTarget
	speed=speedWander

func wait():
	curState=CivState.Wait
	waitDuration=maxWaitDuration*max(0.2,randf())*maxWaitDuration
	curWaitT=0
	speed=0


func panic():
	if curState==CivState.Panic:
		return
	disablePerception()
	curState=CivState.Panic
	doorTarget = Level.layout.GetNearestDoor(position)
	nav.target_position=doorTarget.position
	speed=speedPanic

func remove():
	if is_instance_valid(identity):
		if Level.player.getMaskForIdentity(identity) == null:
			identity.queue_free()
	super.remove()

func _physics_process(delta):
	super._physics_process(delta)
	if isDead():
		return
	match curState:
		CivState.Wander:
			if nav.is_navigation_finished():
				wait()
		CivState.Wait:
			curWaitT+=delta
			if curWaitT>waitDuration:
				chooseWanderPoint()
		CivState.Panic:
			if nav.is_navigation_finished():
				SoundSpawner.SpawnFromName("DoorExit",0.1)
				for c in discoverList:
					if not is_instance_valid(c): # has been freed
						continue
					c.bodyFound()
				remove()
