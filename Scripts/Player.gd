class_name Player
extends RigidBody2D

func _enter_tree():
	Level.player=self

func _physics_process(delta):
	pass

func _process(delta):
	if Input.is_action_just_pressed("Test"):
		die()


signal EV_death
var _dead = false
func die():
	if _dead:
		return
	_dead=true
	EV_death.emit()
func isDead():
	return _dead
