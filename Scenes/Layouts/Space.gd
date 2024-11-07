extends Node2D

const asteroidpath = preload("res://Objects/Space/Asteroid/asteroid.tscn")
const player = preload("res://Objects/Player/Spaceship.tscn")
const enemypath = preload("res://Objects/Space/Enemy/scout.tscn")

# A
var asteroidCount: int
var enemyCount: int
const maxAsteroidCount = 100
const asteroidDistance = 3000


func _ready():
	pass # Replace with function body.

func spawn_asteroid(x,y):
	var asteroid = asteroidpath.instantiate()
	asteroid.player = get_node("Spaceship")
	asteroid.position = Vector2(x,y)
	asteroid.maxDist = asteroidDistance
	get_parent().add_child(asteroid) # Adds the asteroid to the scene tree.

func spawn_enemy(x,y):
	var enemy = enemypath.instantiate()
	enemy.position = Vector2(x,y)
	get_parent().add_child(enemy) # Adds the asteroid to the scene tree.
	enemy.target = get_node("Spaceship")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	asteroidCount = get_tree().get_nodes_in_group("asteroids").size()
	enemyCount = get_tree().get_nodes_in_group("enemies").size()
	
	if asteroidCount < maxAsteroidCount:
		var angle = randf_range(-PI, PI)
		spawn_asteroid(cos(angle) * asteroidDistance + $CameraObj.position.x,sin(angle) * asteroidDistance + $CameraObj.position.y)
	
	if enemyCount < 8:
		var angle2 = randf_range(-PI, PI)
		spawn_enemy(cos(angle2) * asteroidDistance + $CameraObj.position.x,sin(angle2) * asteroidDistance + $CameraObj.position.y)
		#spawn_enemy(50,50) 
	
	$GlobalLightNode.position = $CameraObj.position

	
