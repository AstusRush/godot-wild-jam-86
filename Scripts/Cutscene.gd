extends Node2D

@export var _playTransitionScene : PackedScene

func _enter_tree():
	TutorialChecklist.cutscenePlayed=true
func _process(delta: float):
	TransitionManager.TransitionScene(_playTransitionScene)
