class_name HostileAlarmIndicator
extends Node2D

@export var tog : SmoothToggle
@export var sp : Sprite2D
@export var padding : float = 100

@export var colA : Color
@export var colB : Color
@export var blinkFreq : float = 3

var enemy : EnemyHostile
func setup(e : EnemyHostile):
	enemy=e

func _process(delta):
	if not is_instance_valid(enemy) or enemy.isDead():
		queue_free()
		return
	if enemy.curState == EnemyHostile.HosState.Alarmed:
		modulate=colA if sin(Level.stats.playtime * blinkFreq) > 0 else colB
		position=enemy.position
		var posClamped : Vector2 = position
		posClamped.x = clamp(posClamped.x, Level.camera.position.x-(Level.camera.currentBounds.x/2)+padding , Level.camera.position.x+(Level.camera.currentBounds.x/2)-padding)
		posClamped.y = clamp(posClamped.y, Level.camera.position.y-(Level.camera.currentBounds.y/2)+padding , Level.camera.position.y+(Level.camera.currentBounds.y/2)-padding)
		if posClamped==position: #enemy already in screen
			tog.TriggerOff()
		else:
			position=posClamped
			tog.TriggerOn()

	else:
		tog.TriggerOff()
