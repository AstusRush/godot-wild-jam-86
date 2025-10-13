extends Node2D

var _movementDeltaVec : Vector2
var _movementDeltaMag : float
var _prevPos : Vector2

var _animD : float #distance traveled since animation start
const torsoWiggleMag : float = 20
const torsoWiggleSpeed : float = 0.02
const feetAnimSpeed : float = 0.1

var _spFeet : Sprite2D
var _spTorso : Sprite2D
var _spHead : Sprite2D

@export var enemy : Enemy #can be null

@export var texFeetStanding : Texture2D
@export var texFeetWalk0 : Texture2D
@export var texFeetWalk1 : Texture2D

func _enter_tree():
	_spFeet=get_child(0)
	_spTorso=get_child(1)
	_spHead=get_child(2)
	if enemy != null:
		enemy.EV_Dead.connect(OnDead)

func OnDead(impactForce):
	visible=false

func _process(delta: float):
	_movementDeltaVec=global_position-_prevPos
	_movementDeltaMag=_movementDeltaVec.length()
	_prevPos=global_position
	
	if _movementDeltaMag == 0:
		_animD=0
		_spTorso.rotation_degrees=0
		_spFeet.texture=texFeetStanding
	else:
		_animD+=_movementDeltaMag
		_spTorso.rotation_degrees=sin(_animD*torsoWiggleSpeed)*torsoWiggleMag
		_spFeet.texture = texFeetWalk0 if sin(_animD*feetAnimSpeed) > 0 else texFeetWalk1
		print(_animD)
