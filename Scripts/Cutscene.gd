extends Node2D

@export var _playTransitionScene : PackedScene

func _enter_tree():
	TutorialChecklist.cutscenePlayed=true
func _process(delta: float):
	if Input.is_action_just_pressed("Test"):
		TransitionManager.TransitionScene(_playTransitionScene)
