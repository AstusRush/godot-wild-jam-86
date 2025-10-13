#TODO this has to be freed at some point
class_name HumanIdentity
extends Node

var colorSkin : Color
var colorHair : Color
var colorClothing : Color
var colorFeet : Color

func _init(attachTo : Node):
	colorSkin=Level.colorScheme.skinColors.pick_random()
	colorHair=Level.colorScheme.hairColors.pick_random()
	colorClothing=Level.colorScheme.clothingColors.pick_random()
	colorFeet=Level.colorScheme.clothingColors.pick_random()
	
	attachTo.call_deferred("add_child",self)
