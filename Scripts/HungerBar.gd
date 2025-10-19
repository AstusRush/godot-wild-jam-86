class_name HungerBar
extends Node2D


@export var spIcon : Sprite2D
@export var iconOffset : float = 100
@export var spThreshold : Sprite2D
@export var shaker : Shaker
@export var squash : SquashAnchor
@export var lineSize : int = 700
@export var lineWidth : int = 40

@export var lineBg : Line2D
@export var lineFill : Line2D

@export var colBgStarving : Color
@export var colBgHealthy : Color

@export var colFillStarving : Color
@export var colFillHealthy : Color

@export var iconSinMag : float = 40
@export var iconSinSpeed : float = 2

func _ready():

	
	Level.player.EV_StarvationStart.connect(_onStarvationStart)
	Level.player.EV_StarvationEnd.connect(_onStarvationEnd)
	Level.player.EV_Growl.connect(_onGrowl)
	Level.player.EV_HungerFill.connect(_onHungerFill)


	lineBg.position-=Vector2.RIGHT*(lineSize/2.0)
	
	spIcon.position=lineBg.position+Vector2.RIGHT*(lineSize+iconOffset)
	
	lineFill.position-=Vector2.RIGHT*(lineSize/2.0)
	lineBg.points[1]=Vector2(lineSize,0)
	lineFill.points[1]=Vector2(lineSize,0)
	lineBg.width=lineWidth
	lineFill.width=lineWidth
	
	lineFill.modulate=colFillHealthy
	lineBg.modulate=colBgHealthy
	spIcon.modulate=lineFill.modulate


func updateFill():
	pass

func _onHungerFill():
	squash.TriggerSquash(squash.Small)


func _onGrowl():
	shaker.Trigger()

func _onStarvationStart():
	spThreshold.visible=true
	spThreshold.position=lineBg.position+Vector2.RIGHT*lineSize*(1.0-Level.player.starvationEndPercentage)
	lineFill.modulate=colFillStarving
	lineBg.modulate=colBgStarving
	spIcon.modulate=lineFill.modulate

func _onStarvationEnd():
	squash.TriggerSquash(squash.Medium)
	spThreshold.visible=false
	lineFill.modulate=colFillHealthy
	lineBg.modulate=colBgHealthy
	spIcon.modulate=lineFill.modulate

func _process(delta):
	lineFill.points[1]=lineFill.points[0]+(Vector2.RIGHT*lineSize*Level.player.calcHungerPercentage())
	if Level.player._starving:
		spIcon.rotation_degrees=sin(Level.stats.playtime*iconSinSpeed)*iconSinMag
	else:
		spIcon.rotation_degrees=0
