#global access point for the game scene
extends Node

var player : Player
var camera : GameCamera

var colorScheme : ColorScheme

func _enter_tree():
	colorScheme = load("res://colorscheme.tres")
enum EnemyType{Civilian}
func SpawnEnemy(position : Vector2, type : EnemyType):
	var result : Enemy
	match type:
		EnemyType.Civilian:
			result = load("res://Scenes/Enemies/civilian.tscn").instantiate()
			
	result.position=position
	player.get_parent().add_child(result)
	return result

var testEnemy : Enemy
func _process(delta: float):
	
	if Input.is_action_just_pressed("Test"):
		#if testEnemy==null:
		#testEnemy.navigateTowards(Level.player.position)
		testEnemy = SpawnEnemy(Vector2(MathS.RandSigned()*400,MathS.RandSigned()*400), EnemyType.Civilian)
