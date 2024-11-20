extends Area2D

# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")

# DEPENDANTS

# LIFETIME HANDLING
@onready var MAX_LIFETIME = TYPE_STATS[type][1]
var lifetime = 0

# BULLET MOVEMENT
var moveangle: float
@onready var movespeed = TYPE_STATS[type][0] # Speed at which the bullet will travel
var velocity = Vector2(0,0)
var inertialModifier: Vector2

# STATS PRESETS
#	Will change the stats of the bullet based on the type it is,
#	Vector4( speed , maxLifetime, ? , ? )
var type: int #serve as index to array
const TYPE_STATS: Array = [
	[2000,5,Color(0,1,1,1),0], # type 0 = player
	[1200,8,Color(1,0.15,0.2,1),0], # type 1 = SCOUT
	[1200,8,Color(0,1,1,1),0], # type 2 = NULL
]
# STATS
var damage = 1
var punch = 180

# INITIALIZATION
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# BULLET MOVEMENT UPDATE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Move the bullet based on its speed and angle
	velocity = Vector2.from_angle(moveangle) * Vector2(movespeed,movespeed) + inertialModifier
	lifetime += delta
	
	if lifetime >= MAX_LIFETIME:
		die()
		
	$PointLight2D.color = TYPE_STATS[type][2]
	
	$Beam.frame = type
	$Beam.rotation = moveangle
	position += velocity * delta

func die():
	queue_free()

func body_entered(body):
	if body.is_in_group("damageable"):
		if body.is_in_group("enemies") and type == 0:
			body.damage(self, damage, punch)
		if body.is_in_group("asteroids"):
			body.damage(self, damage, punch)
