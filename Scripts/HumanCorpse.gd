extends Node2D

@export var enemy : Enemy
func _enter_tree():
	visible=false
	enemy.EV_Dead.connect(OnDead)

func OnDead(impactForce):
	visible=true
