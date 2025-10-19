extends Node2D

@export var enemy : Enemy

@export var squash : SquashAnchor
@export var spBody : Sprite2D
@export var spHands : Sprite2D
@export var spHead : Sprite2D
@export var spFeet : Sprite2D
@export var spGuard : Sprite2D
@export var spDog : Sprite2D



func _enter_tree():

	if randf()>0.5:
		scale*=Vector2(-1,1)
	if randf()>0.5:
		scale*=Vector2(1,-1)
	rotation_degrees=randf()*360
	visible=false
	enemy.EV_Dead.connect(OnDead)
	
	spBody.visible=false
	spHands.visible=false
	spHead.visible=false
	spFeet.visible=false
	spGuard.visible=false
	spDog.visible=false
	match enemy.type:
		Level.EnemyType.Civilian:
			var civ : EnemyCivilian = enemy
			spBody.modulate=civ.identity.colorClothing
			spHands.modulate=civ.identity.colorSkin
			spFeet.modulate=civ.identity.colorFeet
			
			spBody.visible=true
			spHands.visible=true
			spHead.visible=true
			spFeet.visible=true
		Level.EnemyType.Guard:
			spGuard.visible=true
		Level.EnemyType.Dog:
			spDog.visible=true
	

func OnDead(impactForce):
	squash.TriggerSquash(squash.Small)
	visible=true
