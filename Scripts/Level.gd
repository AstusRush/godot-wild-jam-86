#global access point for the game scene
extends Node

var player : Player
var camera : GameCamera

enum EnemyType{Civilian}
func SpawnEnemy(position : Vector2, type : EnemyType):
	var result : Enemy
	match type:
		EnemyType.Civilian:
			result = load("res://Scenes/Enemies/civilian.tscn").instantiate()
			
	result.position=position
	player.get_parent().add_child(result)
	return result


func _process(delta: float):
	
	if Input.is_action_just_pressed("Test2"):
		SpawnEnemy(Vector2(MathS.RandSigned()*400,MathS.RandSigned()*400), EnemyType.Civilian)
