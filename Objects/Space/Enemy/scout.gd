extends CharacterBody2D

# CONSTS
const BulletScene = preload("res://Objects/Space/Projectiles/PlayerBullet/Bullet.tscn")

const GROUPS = ["enemies","scouts","damageable"]

# TARGETING
var target: Node2D
var targetPosition: Vector2

# MOVEMENT
var angleToTarget = 0
var speed = 500
var speedModifier = 3
var orbitDist = 0
var impulsion = Vector2(0,0)
var dodgeImpulsion = Vector2(0,0)
var moveangle = 0
var displacement = Vector2(0,0)
var maxSpeed = 1000

var debugga: bool = false

# STATES
var pattern = "Orbit"

# STATS
var health: int
var max_health = 6
var knockbackResistance = 1  #0.1: LOWEST -> 1: AVERAGE -> 2: HIGH -> 4: ABSURD

# OBSTACLES
var frontObstacles: Array = []

func _ready():
	health = max_health
	
	for x in GROUPS:
		add_to_group(x)
	
	orbitDist = randi_range(2,4) * 200

func _physics_process(delta):
	# ANGLE SETTING
	if target != null:
		angleToTarget = (target.position - position).angle()
		targetPosition = Vector2(cos(angleToTarget+PI) * 500, sin(angleToTarget+PI) * 500) + target.global_position
		$PathEnd.global_position = targetPosition
	
	debugga = Input.is_action_pressed("ui_accept")
	
	$FrontSight.visible = debugga
	$PathEnd.visible = debugga
	
	
	if not frontObstacles.is_empty() and global_position.distance_to(get_nearestBody(frontObstacles).global_position) < 100 and not get_nearestBody(frontObstacles).is_in_group("enemies"):
		$Body.global_rotation = (get_nearestBody(frontObstacles).global_position - position).angle()
		spawnBullet($Body.global_rotation)
	else:
		$Body.global_rotation = angleToTarget

	if not frontObstacles.is_empty():
		var crossToTarg = get_crossProduct(Vector2.from_angle(moveangle), get_nearestBody(frontObstacles).global_position - global_position)
		
		moveangle -= delta * (300/crossToTarg) * (300 / global_position.distance_to(get_nearestBody(frontObstacles).global_position))
	else:
		var crossToTarg = get_crossProduct(Vector2.from_angle(moveangle), targetPosition - global_position)
		
		moveangle += delta * clamp((global_position.distance_squared_to(targetPosition)/30000), 0.1, 25) * sign(crossToTarg)
		
	# Movement calculation with dodge impulses
	
	
	speed = clamp(global_position.distance_to(targetPosition) * 2, 0, maxSpeed)
	
	
	
	displacement = lerp(displacement, (Vector2.from_angle(moveangle) * Vector2(speed,speed)), 0.12)
	
	velocity = impulsion + displacement
	
	# Apply rotation to thrusters if above a certain speed
	if velocity.length() > 5:
		$Body/ThrusterA.global_rotation = moveangle
		$Body/ThrusterB.global_rotation = moveangle
		$FrontSight.global_rotation = lerp_angle($FrontSight.global_rotation, moveangle, 0.12) 
	else:
		$FrontSight.global_rotation = $Body.global_rotation
	
	# Gradual decay for impulses
	impulsion = lerp(impulsion, Vector2.ZERO, 0.1)
	
	move_and_slide()
	#spawnBullet(angleToTarget)

# Adjusted dodge impulse function with a limit
func dodgeImpulse(angle, intensity):
	dodgeImpulsion += Vector2(cos(angle) * intensity, sin(angle) * intensity)


func impulse(angle, intensity):
	impulsion += Vector2(cos(angle) *intensity, sin(angle) *intensity)


func spawnBullet(pointing): #PLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDER
	var bullet = BulletScene.instantiate() # Instantiates a new bullet.
	bullet.position = global_position
	get_parent().add_child(bullet) # Adds the bullet to the scene tree.
	bullet.type = 1
	bullet.moveangle = pointing


func get_nearestBody(list) -> Node2D:
	var nearest_body: Node2D = null
	var min_distance = INF
	
	for body in list:
		if body != null:
			var distance = position.distance_to(body.position)
			if distance < min_distance:
				min_distance = distance
				nearest_body = body
	
	return nearest_body

func get_crossProduct(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x


# HANDLING DAMAGE  
func damage(source, amount:int, knockback):
	health -= amount
	# Add effects and shit
	impulse(angleToTarget + PI, 1000)
	if health <= 0:
		die()

# KILL INSTANCE
func die():
	queue_free()


func front_bodyEntered(body):
	if body != null and not frontObstacles.has(body) and not body == self:
		frontObstacles.append(body)


func front_bodyExited(body):
	if frontObstacles.has(body):
		frontObstacles.erase(body)
