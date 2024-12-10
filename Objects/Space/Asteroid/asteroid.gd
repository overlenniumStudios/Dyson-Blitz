#Asteroid.gd
extends RigidBody2D

const GROUPS = ["asteroids", "damageable"]

# DEPENDENCIES
@onready var hiveMind = get_parent().get_node("Fornax Hivemind")
const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")
const DMG_particle = preload("res://Objects/Particles/asteroid_particle.tscn")

var isDoneFor: bool = false
var checkTimer = 0
var chechTimerMAX = 0.5
var assignedTroop = null

const IMPULSE_STRENGTH = 60
const ANGLE_VARIANCE = PI / 6
const MAX_LIFETIME = 1.5 #Maximum Lifetime, in seconds

var knockbackResistance = 2

var maxDist: int
var health: int = 2  # Set initial health for the asteroid
var playerpath = ""
var lifetime = 0
var offscreenTime: float = 0.0  # Variable to count time off-scree
var player: Node2D

var velocity: Vector2 # For compatibility with the position prediction algorithm

# Called when the node enters the scene tree for the first time
func _ready():
	angular_velocity = randf_range(-PI, PI)  # Random angular velocity
	linear_velocity = Vector2(randf_range(-100, 100), randf_range(-100, 100)).normalized() * randf_range(50, 100)
	$Visual/AnimatedSprite.frame = randi_range(0, 6)  # Randomly choose an animation frame
	
	for x in GROUPS:
		add_to_group(x)

func _physics_process(delta):
	$MarkedToDie.visible = isDoneFor
	if assignedTroop != null:
		$MarkedToDie.use_parent_material = true
	else:
		$MarkedToDie.use_parent_material = false
	
	
	if isDoneFor:
		$MarkedToDie.global_rotation = 0
		if checkTimer < chechTimerMAX:
			checkTimer += delta
		else:
			markDestruction()
			checkTimer = 0
	
	if not player == null:
		if position.distance_to(player.position) > maxDist:
			offscreenTime += delta
		else:
			pass
	
	velocity = linear_velocity
	
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		trytoDie(get_global_mouse_position())
	
	scale = Vector2(1.5, 1.5)  # Set a clear scaling factor

	if offscreenTime > MAX_LIFETIME:
		die()

# Function to handle asteroid taking damage
func damage(source, amount: int, knockback):
	health -= amount
	var knockback_angle = source.velocity.angle() + randf_range(-ANGLE_VARIANCE, ANGLE_VARIANCE)
	var impulse_vector = Vector2(cos(knockback_angle), sin(knockback_angle)) * (knockback/knockbackResistance)
	Physics.spawnParticle(DMG_particle, self, 0)
	set_axis_velocity(impulse_vector)
	angular_velocity = (source.velocity.angle() - knockback_angle) * 12
	source.die()  # Destroy bullet
	if health <= 0:
		die()

func die():
	if isDoneFor and assignedTroop != null:
		assignedTroop.target = null # If the asteroid has a troop already assigned to destroy it, It'll remove itself from the target list
	queue_free()

func markDestruction():
	# Make sure the range does not exceed the bounds of the array
	
	if assignedTroop == null:
		
		var start_index = hiveMind.getPreceding("scout_asteroid")
		var end_index = hiveMind.maxTroops[hiveMind.OCCUPATIONS.find("scout_asteroid")] + start_index
		
		var avaliableTroops = []
		
		# Ensure the range is within bounds
		for index in range(start_index, end_index + 1):
			var troop = hiveMind.troops[index]
			if troop != null and troop.target == null:
				avaliableTroops.append(troop)
		
		
		if avaliableTroops.size() > 0:
			assignedTroop = Operations.get_nearestNode(avaliableTroops, global_position)
			assignedTroop.target = self
		else:
			print("No available troops found.")
		
	else:
		if assignedTroop.target == null:
			assignedTroop.target = self
	

func trytoDie(fromPosition):
	if position.distance_squared_to(fromPosition) < 900**2:
		isDoneFor = true
