extends CharacterBody2D

# CONSTANTS
const SPEED = 1000.0
const ACCELERATION = 0.12

# MOVEMENT
var directionraw = Vector2(Input.get_axis("ui_left", "ui_right"), Input.get_axis("ui_up", "ui_down"))
var direction = Vector2(0, 0)
var moveangle = atan2(directionraw.y, directionraw.x)

var controller = true

# MOVEMENT EXTRAS
var appliedvector = Vector2(0,0)
var appliedvector_fallof = 0.4

# SHOOTING
const BULLET_SPAWN_AMOUNT = 2
var BulletScene = preload("res://Objects/Space/Projectiles/PlayerBullet/Bullet.tscn")
var bulletspawn = 0
var shootcooldownmax = 0.25
var shootcooldown = 0

# MOUSE
var mouse = Vector2(0, 0)
var angletomouse = 0

# BULLET SPAWNPOINT CYCLING
func changebulletspawn(): #Cycles through bullet spawn points, wrapping around once it exceeds the total number of spawn points.
	bulletspawn = (bulletspawn + 1) % BULLET_SPAWN_AMOUNT

# BULLET SPAWN HANDLING
func spawnBullet(delta): #Spawns a bullet at the current bullet spawn point and attaches it to the parent node.
	shootcooldown = 0
	var bullet = BulletScene.instantiate() # Instantiates a new bullet.
	bullet.position = $ShipBody/Bulletspawns.get_node("a" + str(bulletspawn)).global_position 
	get_parent().add_child(bullet) # Adds the bullet to the scene tree.
	bullet.moveangle = angletomouse
	bullet.type = 0
	changebulletspawn() # Cycles to the next bullet spawn point
	applyvector(angletomouse + PI, 100)

# IMPULSE PLAYER
func applyvector(angle,intensity):
	appliedvector += Vector2(cos(angle)*intensity,sin(angle)*intensity)

# PHYSICS PROCESS
func _physics_process(delta):
	
	# INPUT HANDLING
	directionraw = Vector2(Input.get_axis("K_left", "K_right"), Input.get_axis("K_up", "K_down")) #Movementkeys input
	if Input.is_action_pressed("Action") and shootcooldown >= shootcooldownmax: #Mouse input
		spawnBullet(delta)
	
	# SHOOT COOLDOWN HANDLING
	if shootcooldown < shootcooldownmax:
		shootcooldown += delta
	
	# CALCULATE MOVEMENT ANGLE AND DIRECTION
	if directionraw.length() > 0: #If there's any movement input, calculate the direction vector using trigonometry.
		moveangle = directionraw.angle()
		direction = Vector2(cos(moveangle),sin(moveangle))
	else:
		direction = Vector2(0, 0)
	
	# GET MOUSE POSITION AND ANGLE TO MOUSE
	
	
	
	if controller:
		if Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y)).length_squared() > 0.01:
			mouse = Vector2(Input.get_joy_axis(0,JOY_AXIS_RIGHT_X), Input.get_joy_axis(0,JOY_AXIS_RIGHT_Y))*Vector2(900,900) + global_position
	else:
		mouse = get_global_mouse_position()
	angletomouse = (mouse - position).angle()
	
	$ShipBody.rotation = angletomouse #Rotate ship to mouse
	
	# MOVEMENT
	appliedvector = lerp(appliedvector, Vector2(0,0), appliedvector_fallof) #Handle appliedvector
	velocity = lerp(velocity, direction * SPEED, ACCELERATION) + appliedvector #Apply displacement
	move_and_slide() #Move da ship

# NOT CLIP TRHOUGH ASTEROIDS
func _on_area_2d_area_entered(area):
	if area.is_in_group("asteroids"):
		applyvector((position - area.position).angle(),velocity.length())
		area.applyvector((position - area.position).angle()+PI,velocity.length()/150)
	print("colidiu")
