class_name Mask
extends Node2D

var enemy : EnemyCivilian
var identity : HumanIdentity

@export var _spHair : Sprite2D

@export var _moveSpeed : float = 100
@export var _faces : Node2D

@export var compromisedToggle : SmoothToggle
@export var squash : SquashAnchor

@export var colorDormant : Color
@export var colorSelectedA : Color
@export var colorSelectedB : Color
var selectedPrev : bool = false
var selectedT : float=0
@export var colorAnimSpeed : float = 4
@export var totalRotationRange : float = 10
@export var hairRotationRange : float = 10
@export var posOffset : Node2D
@export var posOffsetRange : float = 10


var selectedFace : Node2D

func _enter_tree():
	identity=enemy.identity
	_spHair.modulate=identity.colorHair
	_spHair.texture=identity.hairMask
	enemy.EV_DiscoverCorpse.connect(_onDiscoverCorpse)

	var faceIdx = randi_range(0,2)
	selectedFace=_faces.get_child(faceIdx)
	selectedFace.visible=true
	if randf()>0.5: selectedFace.scale*=Vector2(-1,1)
	_spHair.flip_h=randf()>0.5
	_spHair.rotation_degrees=MathS.RandSigned()*hairRotationRange
	selectedFace.get_child(0).modulate=identity.colorSkin

	rotation_degrees=MathS.RandSigned()*totalRotationRange

func _onDiscoverCorpse():
	_compromised=true
	compromisedToggle.TriggerOn()
	enemy=null

func setMaskInsideColor(col : Color):
	selectedFace.get_child(1).color=col
	selectedFace.get_child(2).color=col
	selectedFace.get_child(3).color=col
	

var targetPos : Vector2

var _compromised = false
func IsCompromised():
	return _compromised


func _process(delta: float):
	position+=(targetPos-position) * _moveSpeed * delta

	posOffset.position=Vector2.ZERO
	if Level.player.getEquippedMask()==self:
		selectedT+=delta
		var col = colorSelectedA.lerp(colorSelectedB, MathS.Sin01(selectedT*colorAnimSpeed))
		setMaskInsideColor(col)
		if not selectedPrev: #first frame equipped
			squash.TriggerStretch(SquashAnchor.Medium)
			rotation_degrees=MathS.RandSigned()*totalRotationRange

		if Level.player.isChargingLunge():
			#rotation_degrees=MathS.RandSigned()*totalRotationRange*Level.player.calcChargeP()
			posOffset.position=MathS.RandVec2()*Level.player.calcChargeP()*posOffsetRange

	else:
		setMaskInsideColor(colorDormant)
	selectedPrev=Level.player.getEquippedMask()==self
