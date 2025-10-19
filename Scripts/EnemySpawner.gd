class_name EnemySpawner
extends Node

@export var spawnPointIterations : int = 4
@export var hostileAlarmIndicator : PackedScene


@export var typeStartCounts : Array[int]
@export var typeFirstIncreaseTimestamp : Array[int]
@export var typeIncreaseFrequency : Array[float]
@export var typeMaxCounts : Array[int]
@export var typeRespawnDuration : Array[float]
@export var typeRespawnCurT : Array[float]
@export var typeCurrentCount : Array[float]

@export var alternativePointOffsetDistance : float = 1700

func generateSpawnPoint():
	var bestDist : float = 0
	var bestPoint : Vector2
	var cur : Vector2
	for i in spawnPointIterations:
		cur=MathS.RandVec2()*2000
		if cur.distance_to(Level.player.position) > bestDist:
			bestDist=cur.distance_to(Level.player.position)
			bestPoint=cur

	if Level.camera.isPointInBounds(bestPoint): # try to push point out of the camera
		
		var alternativePositions : Array[Vector2]
		alternativePositions.append(clampToLevelBounds(bestPoint+Vector2.UP*alternativePointOffsetDistance))
		alternativePositions.append(clampToLevelBounds(bestPoint+Vector2.RIGHT*alternativePointOffsetDistance))
		alternativePositions.append(clampToLevelBounds(bestPoint+Vector2.DOWN*alternativePointOffsetDistance))
		alternativePositions.append(clampToLevelBounds(bestPoint+Vector2.LEFT*alternativePointOffsetDistance))
		
		for i in 4:
			if alternativePositions.is_empty():
				break
			var p : Vector2 = alternativePositions.pick_random()
			alternativePositions.erase(p)
			if not Level.camera.isPointInBounds(p):
				bestPoint=p
				break;
	return bestPoint
func clampToLevelBounds(vec : Vector2):
	return Vector2(clamp(vec.x,-2000,2000), clamp(vec.y,-2000,2000))

func _enter_tree():
	Level.spawner=self

func _ready():
	call_deferred("spawnAll")

func spawnAll():
	for t in 3:
		for c in typeStartCounts[t]:
			Level.SpawnEnemy(generateSpawnPoint(),t)

func calcDesiredCount(typeInt : int):
	return min(typeStartCounts[typeInt]+max(floori(((Level.stats.playtime-typeFirstIncreaseTimestamp[typeInt])/typeIncreaseFrequency[typeInt])+1),0),typeMaxCounts[typeInt])

func _physics_process(delta):
	if Level.player.isDead():
		return
	for t in 3:
		var count = calcDesiredCount(t)
		if typeCurrentCount[t] < count: #there is still some room
			typeRespawnCurT[t]+=delta
			if typeRespawnDuration[t] <= typeRespawnCurT[t]:
				typeRespawnCurT[t]-=typeRespawnDuration[t]
				Level.SpawnEnemy(generateSpawnPoint(),t)
				#print("Spawning Type : " + str(t))

func updateCounts():
	for i in 3:
		typeCurrentCount[i]=0
	var enemies : Array[Enemy] = Level.enemies
	for e in enemies:
		if not e.isDead():
			typeCurrentCount[int(e.type)]+=1
