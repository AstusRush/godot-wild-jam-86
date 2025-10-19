class_name PlayerMaskIndicator
extends Node2D
@export var sp : Sprite2D
@export var tog : SmoothToggle
@export var rotSpeed : float

func _process(delta):

    sp.rotation_degrees+=delta*rotSpeed
    var togValue : bool = false
    if not Level.player.isDead():
        if Level.player.getEquippedMask()!=null:
            if Level.player.getEquippedMask()._compromised:
                togValue=true
        if togValue:
            tog.TriggerOn()
        else:
            tog.TriggerOff()