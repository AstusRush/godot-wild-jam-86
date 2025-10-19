class_name Stats
extends Node

var playtime : float
var kills : int

func _enter_tree():
    Level.stats=self
    playtime=0
    kills=0

func _physics_process(delta: float):
    playtime+=delta