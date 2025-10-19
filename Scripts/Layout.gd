class_name Layout
extends Node2D

@export var doors : Node2D

func _enter_tree():
    Level.layout = self

func GetNearestDoor(pos : Vector2):
    var nearestDist : float = INF
    var nearestDoor : Door = null

    for d : Door in doors.get_children():
        if nearestDist > d.position.distance_to(pos):
            nearestDoor=d
            nearestDist=d.position.distance_to(pos)

    return nearestDoor