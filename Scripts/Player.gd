class_name Player
extends RigidBody2D

func _enter_tree():
	Level.player=self

func _physics_process(delta):
	pass

var inputAxis
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


	if Input.is_action_just_pressed("Test"):
		die()

	linear_velocity=inputAxis*500


signal EV_death
var _dead = false
func die():
	if _dead:
		return
	_dead=true
	EV_death.emit()
func isDead():
	return _dead
