class_name MaskHolder
extends Control

@export var distanceBetweenMasks : float = 100
@export var startMaskY : float
@export var equipBoost : float = 20
var _baseY : float
func _enter_tree():
    _baseY=position.y

func _process(delta: float):
    #consistent position when zooming out
    position.y=int(_baseY/Level.camera.zoom.x)

func updateMaskPositions():
    var count : int = Level.player.masks.size()
    if count == 0:
        return
    var totalWidth : float = (count - 1) * distanceBetweenMasks
    for i in count:
        var m : Mask = Level.player.masks[i]
        m.targetPos=Vector2(i*distanceBetweenMasks - (totalWidth/2.0),0)

    if Level.player.getEquippedMask() != null:
        Level.player.getEquippedMask().targetPos+=Vector2.UP*equipBoost
