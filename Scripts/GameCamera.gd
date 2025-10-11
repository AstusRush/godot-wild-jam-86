class_name GameCamera
extends Camera2D

var _desiredPos : Vector2
@export var _mouseOffsetMod : float = 1
@export var _swaySpeed : float = 5

func _enter_tree():
	Level.camera=self

func _process(delta):
	if Level.player.isDead():
		return

	var mouseOffset = get_global_mouse_position()-position
	mouseOffset.x=clamp(mouseOffset.x,-get_viewport_rect().size.x/2,get_viewport_rect().size.x/2)
	mouseOffset.y=clamp(mouseOffset.y,-get_viewport_rect().size.y/2,get_viewport_rect().size.y/2)
	mouseOffset*=_mouseOffsetMod
	
	_desiredPos=Level.player.position
	_desiredPos+=mouseOffset
	
	position+=(_desiredPos-position) * _swaySpeed * delta

func getMouseDir():
	return (get_global_mouse_position()-position).normalized()
