extends Sprite2D

var prog : float = 0
@export var fadeInSpeed : float = 1
@export var fadeOutSpeed : float = 1
@export var rotSpeed : float = 100
@export_range(0,1,0.01) var maxA : float

func _process(delta: float):
	var hiding : bool = false
	if Level.player.getEquippedMask() != null:
		if Level.player.getEquippedMask()._compromised == false:
			hiding=true
	if hiding:
		prog+=fadeInSpeed*delta
	else:
		prog-=fadeOutSpeed*delta

	prog=MathS.Clamp01(prog)
	modulate.a=prog*maxA
	#var mat : ShaderMaterial = material
	#mat.set_shader_parameter("b",prog)

	#size = Vector2.ONE * (Level.camera.currentBounds.x+20)
	#position = -size*0.5
	rotation_degrees+=delta*rotSpeed
