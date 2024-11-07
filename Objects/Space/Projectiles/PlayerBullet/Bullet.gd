extends Area2D

const maxlifetime = 3

var type: int

# BULLET MOVEMENT
var moveangle = 0 # Angle at which the bullet will move
var movespeed = 24 # Speed at which the bullet will travel
var velocity = Vector2(0,0)
var inertialModifier: Vector2

var damage = 1
var punch = 180

var lifetime = 0

# REFERENCE TO PLAYER
var player = "" # Reference to the player node (Spaceship)

@onready var gradient = $PointLight2D.texture as GradientTexture2D

# INITIALIZATION
# Called when the node enters the scene tree for the first time.
func _ready():
	# Get the reference to the player (Spaceship)
	player = get_parent().get_node("Spaceship")
	# Set the move angle to match the angle the player is facing when shooting


# BULLET MOVEMENT UPDATE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Move the bullet based on its speed and angle
	velocity = Vector2(movespeed * cos(moveangle), movespeed * sin(moveangle)) + inertialModifier
	
	lifetime += delta
	
	if lifetime >= maxlifetime:
		die()
	
	$Beam.frame = type
	$Beam.rotation = moveangle
	position += velocity



func die():
	queue_free()


func body_entered(body):
	if body.is_in_group("damageable"):
		if body.is_in_group("enemies") and type == 0:
			body.damage(self, damage, punch)
		if body.is_in_group("asteroids"):
			body.damage(self, damage, punch)
