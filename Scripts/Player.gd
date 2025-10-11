class_name Player
extends RigidBody2D

func _enter_tree():
	Level.player=self

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

var _curLungeCharge = -1

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

	if Input.is_action_pressed("Lunge"):
		if not isChargingLunge():
			_lungeBegin()
	elif Input.is_action_just_released("Lunge"):
		if isChargingLunge():
			_lungeRelease()
	

	if Input.is_action_just_pressed("Test"):
		die()

	modulate.r=1 if not isLunging() else 0


func _physics_process(delta):
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
	


	if isChargingLunge():
		var oldCharge = _curLungeCharge
		_curLungeCharge=min(_curLungeCharge+delta,maxLungeCharge)
		if oldCharge < maxLungeCharge and _curLungeCharge == maxLungeCharge:
			EV_LungeFullyCharged.emit()

func _lungeBegin():
	_curLungeCharge=0
	EV_LungeBegin.emit()
func _lungeRelease():
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
func die():
	if _dead:
		return
	_dead=true
	EV_death.emit()
func isDead():
	return _dead
