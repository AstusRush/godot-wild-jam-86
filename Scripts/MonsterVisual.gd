class_name MonsterVisual
extends Node2D

@export var blobHolder : Node2D
@export var mainBody : Sprite2D
@export var spinSpeed : float = 40
@export var pulsateStrength : float = 0.2
@export var pulsateSpeed : float = 2
var _t : float

@export var colorNormal : Color
@export var colorActive : Color


func _enter_tree():
	blobPos()

func _ready():
	mainBody.rotation_degrees=randf()*360

var visiblePrev

func _process(delta):
	_t+=delta
	mainBody.rotation_degrees+=delta*spinSpeed
	mainBody.scale=Vector2.ONE*(1.0-MathS.Sin01(_t*pulsateSpeed)*pulsateStrength)

	if visiblePrev!=visible:
		blobHolder.visible=visible
		if visible:
			blobPos()

	var newCol : Color = colorNormal
	if Level.player.isLunging():
		newCol=colorActive
	elif Level.player.isChargingLunge():
		newCol=colorNormal.lerp(colorActive,Level.player.calcChargeP())

	if newCol!=mainBody.modulate:
		setColors(newCol)

	visiblePrev=visible

func setColors(col : Color):
	mainBody.modulate=col
	blobHolder.modulate=col

func blobPos():
	for b : MonsterBlob in blobHolder.get_children():
		b.setup(20+50*randf(), randf()*360, 10+randf()*20)
