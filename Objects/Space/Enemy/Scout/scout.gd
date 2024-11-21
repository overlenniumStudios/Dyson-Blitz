#Scout.gd
extends CharacterBody2D

# GROUPS
const GROUPS = ["enemies","scouts","damageable"]
	#switch "SPECIFIC_ENEMY_GROUP" for the group the specific enemy is in.
	#Example: If it's a SCOUT, replace it with "scouts"

# OCCUPATIONS
const TROOP_OCCUPATIONS = ["scout_orbit","scout_asteroid"]
	# The occupations this enemy can have, in order of priority
	# ALL MUST BE CONTAINED WITHIN "OCCUPATIONS" IN TH "hiveMind" INSTANCE


# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")
const BulletScene = preload("res://Objects/Space/Projectiles/GenericBullet/GenBullet.tscn")

# HIVE
@onready var hiveMind = get_parent().get_node("Fornax Hivemind")

# TARGETING
var target: Node2D
var targetPosition: Vector2
var targetPredPos: Vector2

# SHOOTING
const MAX_SPOT = 1
var shootSpot = 0
var shootCooldown = randf()
var shootCooldown_MAX = 1.5 #Time between shots, in SECONDS
@onready var bullet_speed = BulletScene.instantiate().TYPE_STATS[1][1]
var inaccuracyF = 0.25 # varies between 0(Very accurate) and 2(Stupid innacurate). FACTOR of a randomly applied offset

# MOVEMENT
var speed = 0
var speedModifier = 3
var impulsion = Vector2(0,0)
var canMove = 1

# ANGLE
var angleToTarget = 0
var moveangle = 0
var displacement = Vector2(0,0)
var maxSpeed = 1000

#ORBIT
var orbitRadius = 320
var debugga: bool = false

# STATES
var pattern: String

# STATS
var health: int
var max_health = 6
var knockbackResistance = 0.25  #0.1: LOWEST -> 1: AVERAGE -> 2: HIGH -> 4: ABSURD
var lifetime = 0

# OBSTACLES
var frontObstacles: Array = []

func _ready():
	health = max_health
	
	for group in GROUPS:
		add_to_group(group)
	
	getOccupation()

func _physics_process(delta):
	lifetime += delta
	
	scale = Vector2(1.25,1.25)
	
	if pattern == "scout_orbit":
		target = get_parent().get_node("Spaceship")
		inaccuracyF = 0.25
	if pattern == "scout_asteroid":
		inaccuracyF = 0
	
	
	# ANGLE SETTING
	if target != null:
		angleToTarget = (targetPredPos - position).angle()
		targetPosition = Vector2(cos(angleToTarget+PI) * orbitRadius, sin(angleToTarget+PI) * orbitRadius) + target.global_position
		
		
		# PREDICT THE TARGET'S POSITION FOR AIMING
		targetPredPos = Physics.predictContact(target, self, bullet_speed)
		
		$PathEnd.global_position = targetPredPos
		
		# SHOOT AT IT
		shootLoop(delta)
		
		# OBSTACLE AVOIDANCE
		if not frontObstacles.is_empty():
			var nearestObstacle = Operations.get_nearestNode(frontObstacles, position)
			var crossToTarg = Operations.cross_product(Vector2.from_angle(moveangle), nearestObstacle.global_position - global_position)
			
			moveangle -= delta * (300/crossToTarg) * (300 / global_position.distance_to(nearestObstacle.global_position))
			if global_position.distance_squared_to(nearestObstacle.global_position) < 10000 and not get_nearestBody(frontObstacles).is_in_group("enemies"):
				$Body.global_rotation = (nearestObstacle.global_position - position).angle()
		else:
			var crossToTarg = Operations.cross_product(Vector2.from_angle(moveangle), targetPosition - global_position)
			moveangle += delta * clamp((global_position.distance_squared_to(targetPosition)/30000), 0.1, 25) * sign(crossToTarg)
			$Body.global_rotation = angleToTarget
	
	if target == null:
		angleToTarget += delta
		targetPosition = global_position
		$PathEnd.global_position = global_position
		$Body.global_rotation = angleToTarget
	
	debugga = Input.is_action_pressed("ui_accept")
	
	$FrontSight.visible = debugga
	$PathEnd.visible = debugga
	
	# MOVEMENT
	speed = clamp(global_position.distance_to(targetPosition) * 2 * canMove, 0, maxSpeed)
	displacement = lerp(displacement, (Vector2.from_angle(moveangle) * Vector2(speed,speed)), 0.12)
	
	velocity = impulsion + displacement
	
	# Apply rotation to thrusters if above a certain speed
	if velocity.length_squared() > 100000:
		$Body/ThrusterA.global_rotation = moveangle
		$Body/ThrusterB.global_rotation = moveangle
		$FrontSight.global_rotation = lerp_angle($FrontSight.global_rotation, moveangle, 0.12) 
	else:
		$FrontSight.global_rotation = lerp_angle($FrontSight.global_rotation, $Body.global_rotation, 0.12)
	
	# Gradual decay for impulses
	impulsion = lerp(impulsion, Vector2.ZERO, 0.1)
	move_and_slide()


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


# HANDLING DAMAGE  
func damage(source, amount:int, knockback):
	health -= amount
	# Add effects and shit
	Physics.impulse(self, (position - source.position).angle(), knockback/knockbackResistance)
	if health <= 0:
		die()
	source.die()

func getOccupation():
	if pattern != "":
		hiveMind.forgetOccupation(pattern, self)
	
	for job in TROOP_OCCUPATIONS:
		var jobIndex = hiveMind.occupations.find(job)
		var jobGlobalIndex = hiveMind.OCCUPATIONS.find(job)
		
		if hiveMind.maxTroops[jobGlobalIndex] > 0:
			if jobIndex != -1:
				if hiveMind.amount[hiveMind.occupations.find(job)] < hiveMind.maxTroops[jobGlobalIndex]:
					hiveMind.memorizeOccupation(job, self)
					pattern = job
					break
			else:
				hiveMind.memorizeOccupation(job, self)
				pattern = job
				break



# KILL INSTANCE
func die():
	hiveMind.forgetOccupation(pattern, self)
	queue_free()

# SHOOT BULLET EVERY X SECODNS
func shootLoop(delta):
	if shootCooldown >= shootCooldown_MAX:
		var shoot_node = $Body.get_node("Shoot" + str(shootSpot))  # Dynamically access the shoot position node
		if pattern == "orbitRadius":
			spawnBullet($Body.global_rotation + ((randi_range(1,-1)*PI/8) * inaccuracyF), shoot_node.global_position)  # Use the position of the specific shoot spot
		else:
			spawnBullet($Body.global_rotation, shoot_node.global_position)  # Use the position of the specific shoot spot
		shootCooldown = 0
	else:
		shootCooldown += delta

func spawnBullet(pointing, spawnpos: Vector2): #PLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDERPLACEHOLDER
	Physics.spawnBullet(BulletScene, self, spawnpos, angleToTarget, 1)
	Physics.impulse(self, pointing + PI, 300)
	if shootSpot < MAX_SPOT:
		shootSpot += 1
	else:
		shootSpot = 0

func front_bodyEntered(body):
	if body != null and not frontObstacles.has(body) and not body == self and not body.is_in_group("player"):
		frontObstacles.append(body)


func front_bodyExited(body):
	if frontObstacles.has(body):
		frontObstacles.erase(body)
