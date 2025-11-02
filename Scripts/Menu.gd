extends Control

@export var _btnBegin : Button
@export var _btnHelp : Button
@export var _labelCredits : RichTextLabel
@export var _playTransitionScene : PackedScene
@export var _helpTransitionScene : PackedScene

func _enter_tree():
	Level.clear()
	_btnBegin.pressed.connect(_btnBeginPressed)
	_btnHelp.pressed.connect(_btnHelpPressed)
	_labelCredits.text="[center]<POST-JAM VERSION>\n ORIGINALLY MADE FOR GODOT WILD JAM #86 BY " + ("TCHLOK AND ASTUSRUSH" if(randf() > 0.5) else "ASTUSRUSH AND TCHLOK")

func _btnBeginPressed():
	TransitionManager.TransitionScene(_playTransitionScene)

func _btnHelpPressed():
	TransitionManager.TransitionScene(_helpTransitionScene)
