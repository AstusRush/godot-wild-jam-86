extends Node2D

var _t : float
@export var durOpen : float
@export var durClosed : float

var startPos : Vector2
func _ready():
	startPos=position

func _process(delta):
	_t+=delta
	if visible and _t > durOpen:
		visible=false
		_t=0
	elif not visible and _t > durClosed:
		visible=true
		_t=0
	position=startPos+get_global_mouse_position()*0.005
