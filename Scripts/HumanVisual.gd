class_name HumanVisual
extends Node2D

var _movementDeltaVec : Vector2
var _movementDeltaMag : float
var _prevPos : Vector2

var _animD : float #distance traveled since animation start
const torsoWiggleMag : float = 15
const torsoWiggleSpeed : float = 0.025
const feetAnimSpeed : float = 0.03

var _spFeet : Sprite2D
var _spTorso : Sprite2D
var _spHead : Sprite2D
var _spHair : Sprite2D

@export var enemy : Enemy #can be null
@export var texFeetStanding : Texture2D
@export var texFeetWalk0 : Texture2D
@export var texFeetWalk1 : Texture2D


func _enter_tree():
	_spFeet=get_child(0)
	_spTorso=get_child(1)
	_spHead=get_child(2)
	_spHair=get_child(3)
	if enemy != null:
		enemy.EV_Dead.connect(OnDead)

func _ready():
	if enemy != null:
		if enemy.type == Level.EnemyType.Civilian:
			var civilian : EnemyCivilian = enemy
			applyIdentity(civilian.identity)
		else:
			_spHead.texture=load("res://Sprites/Human/Tex_Head_Guard.png")
			_spTorso.texture=load("res://Sprites/Human/Tex_Torso_Guard.png")

func applyIdentity(identity : HumanIdentity):
	_spHead.modulate=identity.colorSkin
	_spTorso.modulate=identity.colorClothing
	_spFeet.modulate=identity.colorFeet
	_spHair.modulate=identity.colorHair
	_spHair.texture=identity.hairTop


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

	if enemy == null:
		if Level.player.getEquippedMask()!=null:
			applyIdentity(Level.player.getEquippedMask().identity)
