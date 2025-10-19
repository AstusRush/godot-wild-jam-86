class_name DogVisual
extends Node2D

@export var enemy : EnemyHostile
@export var sp : Sprite2D
@export var walkA : Texture2D
@export var walkB : Texture2D
@export var flipSpeedMod : float = 1
var t : float

func _process(delta):
	t+=delta
	sp.texture=walkA if sin(t*enemy.linear_velocity.length()*flipSpeedMod) > 0 else walkB
func _enter_tree():
	enemy.EV_Dead.connect(OnDead)
func OnDead(impactForce):
	visible=false

#func _process(delta: float):
#    t+=delta
#func _enter_tree():
#	enemy.EV_Dead.connect(OnDead)
#	
##func _process(delta):
##    t+=delta
##    sp.texture= walkA if sin(t*enemy.linear_velocity.length()*flipSpeedMod) else walkB
#
#func OnDead(impactForce):
#	visible=false
