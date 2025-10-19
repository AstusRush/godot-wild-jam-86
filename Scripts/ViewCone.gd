class_name ViewCone
extends Node2D

@export var circ : DrawCircle
@export var circScale : DrawCircle
@export var borderLeft : Line2D
@export var borderRight : Line2D

@export var notDetectingOpacity : float = 0.2

var enemy : Enemy

func setup(fov : float, distance : float, _enemy : Enemy):
	
	circ.Fill(fov / 360.0)
	circScale.Fill(fov/360.0)
	circ.Radius(distance)
	
	borderLeft.points[0]=Vector2.ZERO
	borderRight.points[0]=Vector2.ZERO
	borderLeft.points[1]=circ.points[0]
	borderRight.points[1]=circ.points[circ.points.size()-1]
	rotation_degrees=-(fov/2)

	enemy = _enemy
	enemy.EV_Dead.connect(_onEnemyDead)
	if circ.Fill()==1:
		borderLeft.visible=false
		borderRight.visible=false

	perceptionUpdate(0)

func perceptionUpdate(p : float):
	circScale.Radius(circ.Radius()*p)
	var col : Color = modulate
	col.a=lerp(notDetectingOpacity,1.0,p)
	modulate=col


func _onEnemyDead(impact : Vector2):
	visible=false
