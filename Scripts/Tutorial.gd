extends Control


var _tSlide : float = 0
var _slideIdx : int

var _transitioning : bool
@export var transitionInDur : float = 1
@export var transitionOutDur : float = 1

@export var minSlideTime : float = 2
@export var slides : Array[Control]


func _enter_tree():
	for s in slides:
		s.visible=true
		s.modulate.a=0

	slides[0].modulate.a=1
	_slideIdx=0

func _process(delta: float):
	_tSlide+=delta
	
	if _transitioning:
		slides[_slideIdx-1].modulate.a = 1.0-min(_tSlide,transitionOutDur) / transitionOutDur # fade out old
		slides[_slideIdx].modulate.a = clamp(_tSlide-transitionOutDur, 0, transitionInDur) / transitionInDur # fade out old

		
		# end transition
		if _tSlide >= transitionInDur + transitionOutDur:
			slides[_slideIdx].modulate.a = 1
			slides[_slideIdx-1].modulate.a = 0
			_transitioning=false
			_tSlide=0

	if Input.is_action_just_pressed("Paused"):
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	
	if not _transitioning:
		if Input.is_action_just_pressed("Lunge") and _tSlide > minSlideTime:
			nextSlide()

func nextSlide():
	_tSlide=0
	_slideIdx+=1
	if _slideIdx < slides.size():
		_transitioning=true
	else:
		returnToMenu()

func returnToMenu():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
