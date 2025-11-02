extends ColorRect

var prog : float = 0
@export var fadeInSpeed : float = 1
@export var fadeOutSpeed : float = 1

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
	var mat : ShaderMaterial = material
	mat.set_shader_parameter("b",prog)

	size = Vector2.ONE * (Level.camera.currentBounds.x+20)
	position = -size*0.5
