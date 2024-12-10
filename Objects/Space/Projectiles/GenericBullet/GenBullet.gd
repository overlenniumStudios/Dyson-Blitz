extends Area2D

# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")

# DEPENDANTS

# LIFETIME HANDLING
var lifetime = 0
var MAX_LIFETIME: int

# BULLET MOVEMENT
var moveangle: float
var velocity = Vector2(0,0)
var inertialModifier: Vector2
var movespeed: int

# STATS PRESETS
#	Will change the stats of the bullet based on the type it is,
#	Vector4( speed , maxLifetime, ? , ? )
var type: int #serve as index to array
const TYPE_STATS: Array = [
	[2000,5,Color(0,1,1,1),1,300], # type 0 = player
	[1200,8,Color(1,0.15,0.2,1),2,180], # type 1 = SCOUT
	[1200,8,Color(0,1,1,1),0,0], # type 2 = NULL
]
# STATS
var damage: int
var punch: int

var isReady = false

# INITIALIZATION
# Called when the node enters the scene tree for the first time.
func _ready():
	$Beam.visible = false

func start():
	movespeed    = TYPE_STATS[type][0] # Speed at which the bullet will travel
	MAX_LIFETIME = TYPE_STATS[type][1]
	$PointLight2D.color = TYPE_STATS[type][2]
	damage = TYPE_STATS[type][3]
	punch  = TYPE_STATS[type][4]
	isReady = true

# BULLET MOVEMENT UPDATE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if isReady:
		# Move the bullet based on its speed and angle
		velocity = Vector2.from_angle(moveangle) * Vector2(movespeed,movespeed) + inertialModifier
		lifetime += delta
		$Beam.visible = true
		if lifetime >= MAX_LIFETIME:
			die()
		
		
		
		$Beam.frame = type
		$Beam.rotation = moveangle
		position += velocity * delta



func die():
	$PointLight2D.enabled = false
	queue_free()

func body_entered(body):
	if body.is_in_group("damageable"):
		if body.is_in_group("enemies") and type == 0:
			body.damage(self, damage, punch)
		if body.is_in_group("player") and type == 1:
			body.damage(self, damage, punch)
		if body.is_in_group("asteroids"):
			body.damage(self, damage, punch)
