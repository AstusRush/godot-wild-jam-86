extends Node2D
@export var enemy : EnemyHostile
var _tog : SmoothToggle
var _rotDir : int
const rotSpeed : float = 100


func _enter_tree():
    _tog=get_child(0)
    enemy.EV_ChaseStart.connect(_onChaseStart)
    enemy.EV_ChaseEnd.connect(_onChaseEnd)
    enemy.EV_Dead.connect(_onDead)

func _onChaseStart():
    _tog.TriggerOn()
    _rotDir = 1 if randf() > 0.5 else -1

func _process(delta: float):
    rotation_degrees+=rotSpeed*_rotDir*delta

func _onChaseEnd():
    _tog.TriggerOff()

func _onDead(impactForce : Vector2):
    _tog.TriggerOff()
