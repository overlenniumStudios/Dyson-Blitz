extends RigidBody2D

const GROUPS = ["asteroids", "damageable"]

const DMG_particle = preload("res://Objects/Particles/asteroid_particle.tscn")
const IMPULSE_STRENGTH = 60
const ANGLE_VARIANCE = PI / 6
const MAX_LIFETIME = 1.5 #Maximum Lifetime, in seconds

var knockbackResistance = 3

var maxDist: int
var health: int = 3  # Set initial health for the asteroid
var playerpath = ""
var lifetime = 0
var offscreenTime: float = 0.0  # Variable to count time off-scree
var player: Node2D

# Function to handle asteroid taking damage
func damage(source, amount: int, knockback):
	health -= amount
	var knockback_angle = source.velocity.angle() + randf_range(-ANGLE_VARIANCE, ANGLE_VARIANCE)
	var impulse_vector = Vector2(cos(knockback_angle), sin(knockback_angle)) * (knockback/knockbackResistance)
	spawn_particle(DMG_particle)
	set_axis_velocity(impulse_vector)
	angular_velocity = (source.velocity.angle() - knockback_angle) * 12
	source.die()  # Destroy bullet
	if health <= 0:
		die()

func die():
	queue_free()

# Spawns a particle effect at the asteroid's position
func spawn_particle(type):
	var particle = type.instantiate()
	particle.position = position
	get_parent().add_child(particle)

# Called when the node enters the scene tree for the first time
func _ready():
	angular_velocity = randf_range(-PI, PI)  # Random angular velocity
	linear_velocity = Vector2(randf_range(-100, 100), randf_range(-100, 100)).normalized() * randf_range(50, 100)
	$Visual/AnimatedSprite.frame = randi_range(0, 6)  # Randomly choose an animation frame
	
	
	for x in GROUPS:
		add_to_group(x)

func _physics_process(delta):
	if not player == null:
		if position.distance_to(player.position) > maxDist:
			offscreenTime += delta
		else:
			pass
	
	scale = Vector2(1.5, 1.5)  # Set a clear scaling factor

	if offscreenTime > MAX_LIFETIME:
		die()
