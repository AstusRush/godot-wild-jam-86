class_name EnemyCivilian
extends Enemy

var identity : HumanIdentity

func _enter_tree():
	super._enter_tree()
	identity = HumanIdentity.new(get_parent())
