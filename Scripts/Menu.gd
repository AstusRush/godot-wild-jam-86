extends Control

@export var _btnBegin : Button
@export var _labelCredits : RichTextLabel
@export var _playTransitionScene : PackedScene

func _enter_tree():
	Level.clear()
	_btnBegin.pressed.connect(_btnBeginPressed)
	_labelCredits.text="[center]MADE BY " + ("TCHLOK AND ASTUSRUSH" if(randf() > 0.5) else "ASTUSRUSH AND TCHLOK") + "\nFOR GODOT WILD JAM #86"

func _btnBeginPressed():
	TransitionManager.TransitionScene(_playTransitionScene)
