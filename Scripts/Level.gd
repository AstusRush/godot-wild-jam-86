#global access point for the game scene
extends Node2D

func clear():
	player = null
	camera = null
	layout = null
	paused = null
	stats = null
	spawner = null
	enemies.clear()

var player : Player
var camera : GameCamera
var layout : Layout
var paused : Paused
var stats : Stats
var spawner : EnemySpawner

var colorScheme : ColorScheme

var enemies : Array[Enemy]



func _enter_tree():
	position=Vector2.ZERO
	colorScheme = load("res://colorscheme.tres")
	Input.set_custom_mouse_cursor(load("res://Sprites/Tex_Cursor.png"),Input.CursorShape.CURSOR_ARROW,Vector2(50,50))


enum EnemyType{Civilian,Guard,Dog}
func SpawnEnemy(position : Vector2, type : EnemyType):
	var result : Enemy
	match type:
		EnemyType.Civilian:
			result = load("res://Scenes/Enemies/civilian.tscn").instantiate()
		EnemyType.Guard:
			result = load("res://Scenes/Enemies/guard.tscn").instantiate()
		EnemyType.Dog:
			result = load("res://Scenes/Enemies/dog.tscn").instantiate()
	result.position=position
	player.get_parent().add_child(result)
	enemies.append(result)
	Level.spawner.updateCounts()

	if type != Level.EnemyType.Civilian:
		var alert : HostileAlarmIndicator = spawner.hostileAlarmIndicator.instantiate()
		alert.setup(result)
		player.get_parent().add_child(alert)
	return result

func getEnemiesOfType(type : EnemyType):
	var result : Array[Enemy]
	for e in enemies:
		if e.type==type:
			result.append(e)
	return result
func getEnemiesDead():
	var result : Array[Enemy]
	for e in enemies:
		if e.isDead():
			result.append(e)
	return result
func getEnemiesHostile():
	var result : Array[Enemy]
	result.append_array(getEnemiesOfType(Level.EnemyType.Guard))
	result.append_array(getEnemiesOfType(Level.EnemyType.Dog))
	return result
