class_name Player
extends RigidBody2D

var inputAxis=Vector2.ZERO
var movementAxis=Vector2.ZERO

@export var movementSpeed = 500 # max player speed when not using lunge
@export var baseAccel : float = 500
@export var baseDrag : float = 100
@export var baseDecel : float = 500
@export var jitterSnapThreshold = 10
@export var maxCounterMod : float = 2 # modifier applied when changing direction

@export var lungeSpeedMin = 1000
@export var lungeSpeedMax = 2000
@export var lungeDrag = 1000
@export var lungeAccel = 200
@export var maxLungeCounterMod : float = 2

@export var maxLungeCharge : float = 1

@export var heartHolder : HeartHolder

var _curLungeCharge = -1

@export var attackBox : Area2D


var _hitList : Array[Enemy] # to prevent enemies from getting hit twice in a single lunge

@export var maskCountLimit : int = 3
var masks : Array[Mask]
var _equippedMaskIdx : int = -1
@export var maskHolder : MaskHolder
@export var maskPacked : PackedScene

@export var monsterVisual : MonsterVisual
@export var humanVisual : HumanVisual

var health : int


#hunger

@export var hungerCapacity : int = 100
@export var growlFrequency : float = 5
@export var hungerBaseDrain : float = 1
@export var killNutrition : int
@export var maskNutrition : int
@export var hungerCostLunge : int = 10
@export_range(0,1,0.01) var starvationEndPercentage : float

var _starving : bool
var _growlT : float
var hungerCur : float

signal EV_StarvationStart
signal EV_StarvationEnd
signal EV_Growl
signal EV_HungerFill





func _enter_tree():
	health=3
	Level.player=self
	attackBox.body_entered.connect(_onAttackBoxBodyEntered)
	humanVisual.visible=false
	monsterVisual.visible=true
	hungerCur=hungerCapacity

func _ready():
	pass


func _process(delta):
	inputAxis = Vector2.ZERO
	if Input.is_action_pressed("MoveUp"):
		inputAxis+=Vector2.UP
	if Input.is_action_pressed("MoveDown"):
		inputAxis+=Vector2.DOWN
	if Input.is_action_pressed("MoveRight"):
		inputAxis+=Vector2.RIGHT
	if Input.is_action_pressed("MoveLeft"):
		inputAxis+=Vector2.LEFT
	movementAxis=inputAxis.normalized()
	
	if isDead():
		movementAxis=Vector2.ZERO
	else:
		if Input.is_action_pressed("Lunge"):
			if not isChargingLunge() and not isLunging():
				_lungeBegin()
		elif Input.is_action_just_released("Lunge"):
			if isChargingLunge():
				_lungeRelease()

		if Input.is_action_just_pressed("CycleMaskRight"):
			cycleMask(1)
		elif Input.is_action_just_pressed("CycleMaskLeft"):
			cycleMask(-1)

	monsterVisual.visible=false
	if getEquippedMask()==null:
		monsterVisual.visible=true
	if isLunging():
		monsterVisual.visible=true
	humanVisual.visible=not monsterVisual.visible

	if linear_velocity != Vector2.ZERO:
		humanVisual.rotation_degrees=MathS.VecToDeg(linear_velocity)+90
	#if Input.is_action_just_pressed("Eat") and getEquippedMask()!=null:
	#	fillHunger(maskNutrition)
	#	discardMask(_equippedMaskIdx)

func _physics_process(delta):
	var hungerDrainMod : float = 1
	#attackBox.position=position
	curDamageCd = max(0,curDamageCd-delta)
	var finalStep = Vector2.ZERO
	var mag : int = floori(linear_velocity.length()) # must be int to prevent floating point imprecision problem

	# default movement mode
	if movementSpeed >= mag:
		var dragStep = -linear_velocity * baseDrag * delta
		finalStep+=dragStep
		
		if movementAxis==Vector2.ZERO:
			var decelStep = -linear_velocity.normalized() * baseDecel * delta
			finalStep+=decelStep
		else:
			var accelStep = movementAxis * baseAccel * delta
			# calculate modifier for switching directions
			var dot = (linear_velocity.normalized()).dot(movementAxis)
			dot = 1.0-((dot+1)/2.0)
			accelStep *= lerp(1.0,maxCounterMod, dot)
			finalStep+=accelStep

		linear_velocity += finalStep
		# magnitude of new linear_velocity shouldn't go above movementSpeed
		linear_velocity = linear_velocity.normalized()*min(linear_velocity.length(), movementSpeed)
		if linear_velocity.length() < jitterSnapThreshold and  movementAxis==Vector2.ZERO : #should prevent jitter
			linear_velocity=Vector2.ZERO
		
	# lunge movement mode
	else:
		finalStep += -linear_velocity.normalized()*lungeDrag*delta

		# accelStep should only slightly affect the trajectory
		var accelStep = movementAxis * lungeAccel * delta
		# calculate modifier for switching directions
		var dot = (linear_velocity.normalized()).dot(movementAxis)
		dot = 1.0-((dot+1)/2.0)
		accelStep *= lerp(1.0,maxLungeCounterMod, dot)
		
		finalStep += accelStep

		linear_velocity += finalStep
	
	attackBox.monitoring=isLunging()

	if isChargingLunge():
		var oldCharge = _curLungeCharge
		_curLungeCharge=min(_curLungeCharge+delta,maxLungeCharge)
		if oldCharge < maxLungeCharge and _curLungeCharge == maxLungeCharge:
			EV_LungeFullyCharged.emit()


	#hunger
	if not isDead():
		if hungerCur > 0:
			hungerCur-=delta*hungerDrainMod*hungerBaseDrain
			if hungerCur <= 0:
				if not _starving:
					_starving=true
					hungerCur=0
					EV_StarvationStart.emit()
					growl()

		if _starving:
			_growlT+=delta
			if _growlT>=growlFrequency:
				growl()

func fillHunger(amount : float):
	hungerCur=min(hungerCapacity, hungerCur+amount)
	if _starving and hungerCur >= float(hungerCapacity)*starvationEndPercentage:
		_starving=false
		EV_StarvationEnd.emit()
	else:
		EV_HungerFill.emit()

func drainHunger(amount : float):
	if hungerCur==0:
		return
	hungerCur=max(0,hungerCur-amount)
	if hungerCur==0:
		_starving=true
		EV_StarvationStart.emit()
		growl()
	

func growl():
	SoundSpawner.SpawnFromName("Growl")
	EV_Growl.emit()
	var hostiles : Array[Enemy] = Level.getEnemiesHostile()
	for h : EnemyHostile in hostiles:
		h.alarm()
	_growlT=0
	ParticleSpawner.SpawnFromName("Soundwave",Level.player.position)

func calcHungerPercentage():
	return MathS.Clamp01(float(hungerCur)/float(hungerCapacity))

func _lungeBegin():
	drainHunger(hungerCostLunge)
	_hitList.clear()
	_curLungeCharge=0
	EV_LungeBegin.emit()
func _lungeRelease():
	SoundSpawner.SpawnFromName("DashRelease",0.1)
	if getEquippedMask()!=null:
		discardMask(_equippedMaskIdx)
	var finalSpeed = lerp(lungeSpeedMin, lungeSpeedMax, calcChargeP())
	linear_velocity = Level.camera.getMouseDir() * finalSpeed
	EV_LungeRelease.emit()
	_curLungeCharge=-1 # reset charge state to not charging

func isChargingLunge():
	return _curLungeCharge >= 0
func calcChargeP():
	return _curLungeCharge/maxLungeCharge
func isLunging():
	return movementSpeed < floori(linear_velocity.length())


signal EV_LungeFullyCharged
signal EV_LungeBegin
signal EV_LungeRelease

signal EV_death
var _dead = false

func isInvincible():
	return curDamageCd > 0
@export var hitInvincibilityDuration : float = 0.75
var curDamageCd : float
func damage(vec : Vector2):
	if isDead() or curDamageCd > 0:
		return
	curDamageCd=hitInvincibilityDuration
	Level.player.health-=1
	if Level.player.health == 0:
		Level.player.die()
		Level.paused.hitstopLong()
		Level.camera._screenshakeStrength*=1.5
	else:
		SoundSpawner.SpawnFromName("PlayerHit")
	Level.camera.screenshake()

	heartHolder.destroyHeart()

func die():
	if _dead:
		return
	SoundSpawner.SpawnFromName("PlayerDeath")
	_dead=true
	linear_velocity=Vector2.ZERO
	EV_death.emit()
	visible=false
	_curLungeCharge=-1
func isDead():
	return _dead

func _onAttackBoxBodyEntered(body):
	var enemy : Enemy = body
	if _hitList.has(enemy):
		return
	
	if not enemy.isDead():
		fillHunger(killNutrition)
		SoundSpawner.SpawnFromName("EnemyHit",0.2)
		Level.camera.screenshake()
		Level.paused.hitstop()
		Level.stats.kills+=1

		if enemy.type==Level.EnemyType.Civilian:
			if masks.size() < maskCountLimit: # collect mask
				var enemyC : EnemyCivilian = enemy
				var m : Mask = maskPacked.instantiate()
				m.enemy=enemyC
				masks.append(m)
				maskHolder.add_child(m)
				maskHolder.updateMaskPositions()
				m.global_position=enemyC.global_position
				if getEquippedMask()==null:
					equipMask(0)

	enemy.hit(linear_velocity)
	
	_hitList.append(enemy)

func getEquippedMask():
	if _equippedMaskIdx == -1:
		return null
	return masks[_equippedMaskIdx]

func getMaskForIdentity(identity : HumanIdentity):
	for m in masks:
		if m.identity==identity:
			return m
	return null

func isDisguised():
	return getEquippedMask()!=null and not getEquippedMask().IsCompromised()

func equipMask(idx : int):
	if idx == _equippedMaskIdx:
		return
	_equippedMaskIdx=idx
	humanVisual.applyIdentity(getEquippedMask().identity)
	maskHolder.updateMaskPositions()

func cycleMask(dir:int):
	if _equippedMaskIdx==-1:
		return
	var newIdx = _equippedMaskIdx
	newIdx+=dir
	if newIdx < 0:
		newIdx = masks.size()-1
	elif newIdx > masks.size()-1:
		newIdx=0
	
	equipMask(newIdx)


func discardMask(idx : int):
	var m : Mask = masks[idx]
	masks.remove_at(idx)
	m.identity.queue_free()
	m.queue_free()
	if masks.size()==0:
		_equippedMaskIdx=-1
	else:
		_equippedMaskIdx=0
		for i in masks.size(): #try to equip uncompromised mask.
			if not masks[i].IsCompromised():
				_equippedMaskIdx=i
				break
		equipMask(_equippedMaskIdx)
	maskHolder.updateMaskPositions()
