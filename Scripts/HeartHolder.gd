class_name HeartHolder
extends Node2D

@export var texNormal : Texture2D
@export var texBroken : Texture2D
@export var colorNormal : Color
@export var colorBroken : Color

func _enter_tree():
	for i : Sprite2D in get_children():
		i.texture=texNormal
		i.modulate=colorNormal

func destroyHeart():
	var target : Sprite2D = get_child(Level.player.health)
	target.texture=texBroken
	var par :Node2D = ParticleSpawner.SpawnFromName("HeartExplode",target.global_position)
	par.modulate=colorNormal
	target.texture=texBroken
	target.modulate=colorBroken
