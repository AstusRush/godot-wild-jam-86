#TODO this has to be freed at some point
class_name HumanIdentity
extends Node

var colorSkin : Color
var colorHair : Color
var colorClothing : Color
var colorFeet : Color

var hairTop : Texture2D
var hairMask : Texture2D
const hairVariantCount : int = 4



func _init(attachTo : Node):
	colorSkin=Level.colorScheme.skinColors.pick_random()
	colorHair=Level.colorScheme.hairColors.pick_random()
	colorClothing=Level.colorScheme.clothingColors.pick_random()
	colorFeet=Level.colorScheme.shoeColors.pick_random()
	
	var hairIdx = randi_range(-1,hairVariantCount-1)
	if hairIdx == -1: # bald
		hairTop=null
		hairMask=null
	else:
		hairTop=load("res://Sprites/Human/Hairstyles/Tex_Hair_" + str(hairIdx) + ".png")
		hairMask=load("res://Sprites/Human/Hairstyles/Mask/Tex_Hair_Mask_"+ str(hairIdx) +".png")

	attachTo.call_deferred("add_child",self)
