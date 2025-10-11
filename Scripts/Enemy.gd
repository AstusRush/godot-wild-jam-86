class_name Enemy
extends RigidBody2D

var _dead = false
const DeadDampening = 5
const ImpactForceMod = 1.2
const CollisionMaskAlive = 0
const CollisionMaskDead = 4 + 2 # can now collide with walls and other enemies

func _enter_tree():
	linear_damp=0
	collision_mask=CollisionMaskAlive # not colliding with anything

func _process(delta):
	pass
	
func hit(impactForce : Vector2):
	linear_velocity=impactForce*ImpactForceMod
	if not _dead:
		modulate.r=0
		modulate.b=0
		modulate.g=0
		linear_damp=DeadDampening
		collision_mask=CollisionMaskDead
	else:
		_dead=true
