class_name GameCamera
extends Camera2D

var _desiredPos : Vector2
@export var _mouseOffsetMod : float = 1
@export var _swaySpeed : float = 5
@export var _screenshakeDuration : float = 0.15
@export var _screenshakeStrength : int = 6
@export var _screenshakeEase : MathS.EasingMethod
var  _screenshakeRemaining : float = 0

func _enter_tree():
	Level.camera=self

@export var _zoomReturnSpeed : float = 0.5
@export var _zoomModNormal :float = 1
@export var _zoomModFullCharged : float = 0.8

var currentBounds : Vector2
func _process(delta):
	
	var mouseOffset = get_global_mouse_position()-position
	if Level.player.isDead():
		mouseOffset=Vector2.ZERO
	mouseOffset.x=clamp(mouseOffset.x,-get_viewport_rect().size.x/2,get_viewport_rect().size.x/2)
	mouseOffset.y=clamp(mouseOffset.y,-get_viewport_rect().size.y/2,get_viewport_rect().size.y/2)
	mouseOffset*=_mouseOffsetMod
	_desiredPos=Level.player.position
	_desiredPos+=mouseOffset
	position+=(_desiredPos-position) * _swaySpeed * delta



	if Level.player.isChargingLunge(): #zoom out
		zoom.x =min(zoom.x,lerp(_zoomModNormal,_zoomModFullCharged,Level.player.calcChargeP()))
		zoom.y=zoom.x
	elif not Level.player.isLunging(): #return to normal zoom
		zoom.x=min(_zoomModNormal, zoom.x+delta*_zoomReturnSpeed)
		zoom.y=zoom.x


	var shakeMag = MathS.Ease(_screenshakeRemaining/_screenshakeDuration, _screenshakeEase)*_screenshakeStrength
	shakeMag/=zoom.x # makes screenshake consistent for different zoom values
	position+=MathS.RandDir2()*shakeMag
	_screenshakeRemaining = max(_screenshakeRemaining-delta, 0)


	currentBounds=Vector2(1152.0,1152.0)/zoom

func getMouseDir():
	return (get_global_mouse_position()-position).normalized()

func isPointInBounds(p : Vector2):
	if p.x>position.x+(currentBounds.x/2):
		return false
	if p.x<position.x-(currentBounds.x/2):
		return false
	if p.y>position.y+(currentBounds.y/2):
		return false
	if p.y<position.y-(currentBounds.y/2):
		return false

	return true

func screenshake():
	_screenshakeRemaining=_screenshakeDuration
