class_name Mask
extends Node2D

var enemy : EnemyCivilian
var identity : HumanIdentity

@export var _spSkin : Sprite2D
@export var _spHair : Sprite2D

@export var _moveSpeed : float = 100

@export var compromisedToggle : SmoothToggle

func _enter_tree():
	identity=enemy.identity
	_spSkin.modulate=identity.colorSkin
	_spHair.modulate=identity.colorHair
	enemy.EV_DiscoverCorpse.connect(_onDiscoverCorpse)

func _onDiscoverCorpse():
	_compromised=true
	compromisedToggle.TriggerOn()
	enemy=null


var targetPos : Vector2

var _compromised = false
func IsCompromised():
	return _compromised


func _process(delta: float):
	position+=(targetPos-position) * _moveSpeed * delta
