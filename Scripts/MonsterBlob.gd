class_name MonsterBlob
extends Sprite2D

var playerOffset : Vector2
var _speed : float
var _rotSpeed : float

func setup(distance,angle, speed):
    playerOffset=MathS.DegToVec(angle)*distance
    _speed=speed
    _rotSpeed=MathS.RandSigned()*200

func _process(delta):
    position+=((Level.player.position+playerOffset)-position) * _speed * delta
    rotation_degrees+=_rotSpeed*delta