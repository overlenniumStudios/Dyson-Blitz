extends Area2D

# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")
const gradientRES = preload("res://Shaders/Lighting/GlowSmall.tres")

# DEPENDANTS


# LIFETIME HANDLING
@onready var MAX_LIFETIME = TYPE_STATS[type].y
var lifetime = 0

# BULLET MOVEMENT
var moveangle = 0 # Angle at which the bullet will move
@onready var movespeed = TYPE_STATS[type].x # Speed at which the bullet will travel
var velocity = Vector2(0,0)
var inertialModifier: Vector2

# STATS PRESETS
#	Will change the stats of the bullet based on the type it is,
#	Vector4( speed , maxLifetime, ? , ? )
var type: int #serve as index to array
const TYPE_STATS: Array = [
	Vector4(2000,5,0,0), # type 0 = player
	Vector4(1200,8,0,0), # type 1 = SCOUT
	Vector4(0,0,0,0)  # type 2 = [FUTURE]
]

# COLORS
const COLORS_ARRAY: Array = [
	Color(0, 1, 1, 1), # Cyan, TYPE 0
	Color(1, 0, 0, 1)  # Red, TYPE 0
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
	velocity = Vector2(movespeed * cos(moveangle), movespeed * sin(moveangle)) + inertialModifier
	
	lifetime += delta
	
	if lifetime >= MAX_LIFETIME:
		die()
	
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
