extends CharacterBody2D

# CONSTANTS
const SPEED = 750.0
const ACCELERATION = 0.12

const GROUPS = ["player", "damageable"]

# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")
const damageParticle = preload("res://Objects/Particles/Destruction/SparksAimed.tscn")

# SIGNALING
signal health_changed(new_health, max_health)

# MOVEMENT
var directionraw = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
var direction = Vector2(0, 0)
var moveangle = atan2(directionraw.y, directionraw.x)

var controller = false

# MOVEMENT EXTRAS
var impulsion = Vector2(0,0)
var impulseFallof = 0.2

# SHOOTING
const BULLET_SPAWN_AMOUNT = 2
var BulletScene = preload("res://Objects/Space/Projectiles/GenericBullet/GenBullet.tscn")
var bulletspawn = 0
var shootcooldownmax = 0.25
var shootcooldown = 0

# MOUSE
var mouse = Vector2(0, 0)
var angletomouse = 0

#VISUAL
var noiseFade = 1.0

# STATS
var health: int
var maxHealth = 20

func _ready():
	for group in GROUPS:
		add_to_group(group)
	
	changeHealth(maxHealth-health)

# PHYSICS PROCESS
func _physics_process(delta):
	
	# INPUT HANDLING
	directionraw = Vector2(Input.get_axis("K_left", "K_right"), Input.get_axis("K_up", "K_down")) #Movementkeys input
	
	if noiseFade < 1.0:
		noiseFade += delta/3.0
	if noiseFade < 0.0:
		noiseFade = 0.0
	
	$ShipBody/Sprite2D.material.set_shader_parameter("intensity", noiseFade)
	
	if Input.is_action_pressed("Action") and shootcooldown >= shootcooldownmax: #Mouse input
		spawnBullet(delta)
	
	# SHOOT COOLDOWN HANDLING
	if shootcooldown < shootcooldownmax:
		shootcooldown += delta
	
	# CALCULATE MOVEMENT ANGLE AND DIRECTION
	direction = directionraw.normalized()
	
	# GET MOUSE POSITION AND ANGLE TO MOUSE
	
	
	
	if controller:
		if Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)).length_squared() > 0.01:
			mouse = Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))*Vector2(900,900) + global_position
	else:
		mouse = get_global_mouse_position()
	angletomouse = (mouse - position).angle()
	
	$ShipBody.rotation = angletomouse #Rotate ship to mouse
	
	# MOVEMENT
	impulsion = lerp(impulsion, Vector2(0,0), impulseFallof) #Handle appliedvector
	velocity = lerp(velocity, direction * SPEED, ACCELERATION) + impulsion #Apply displacement
	
	move_and_slide() #Move da ship

# BULLET SPAWNPOINT CYCLING
func changebulletspawn(): #Cycles through bullet spawn points, wrapping around once it exceeds the total number of spawn points.
	bulletspawn = (bulletspawn + 1) % BULLET_SPAWN_AMOUNT

# BULLET SPAWN HANDLING
func spawnBullet(delta): #Spawns a bullet at the current bullet spawn point and attaches it to the parent node.
	shootcooldown = 0
	Physics.spawnBullet(BulletScene, self, $ShipBody/Bulletspawns.get_node("a" + str(bulletspawn)).global_position , angletomouse, 0)
	changebulletspawn() # Cycles to the next bullet spawn point
	Physics.impulse(self, angletomouse + PI, 100)

func damage(body, damage, knockback):
	Physics.impulse(self, body.moveangle, knockback)
	Physics.spawnParticle(damageParticle, self, body.moveangle)
	body.die()
	noiseFade = noiseFade/2.0
	changeHealth(-1)
	print(self, " took damage! New HP: ", health)

func changeHealth(factor):
	health += factor
	emit_signal("health_changed", health, maxHealth)
	if health <= 0:
		health = maxHealth
