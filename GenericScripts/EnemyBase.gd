extends CharacterBody2D

# GROUPS
const GROUPS = ["enemies","SPECIFIC_ENEMY_GROUP","damageable"] 
	#switch "SPECIFIC_ENEMY_GROUP" for the group the specific enemy is in.
	#Example: If it's a SCOUT, replace it with "scouts"

# OCCUPATIONS
const TROOP_OCCUPATIONS = ["occupationA", "occupationB", "occupationC"]
	# The occupations this enemy can have, in order of priority
	# ALL MUST BE CONTAINED WITHIN "OCCUPATIONS" IN TH "hiveMind" INSTANCE

# DEPENDENCIES
@onready var hiveMind = get_parent().get_node("Fornax Hivemind")
const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")
#const BulletScene = preload("PATH_TO_PROJECTILES")

# TARGETING
var target: Node2D

# MOVEMENT
var pattern: String
var angleToTarget = 0
var speed = 0
var impulsion = Vector2.ZERO
var velocityRaw = Vector2.ZERO

# STATS
var health: int
var max_health = 99
var knockbackResistance = 1  #0.1: LOWEST -> 1: AVERAGE -> 2: HIGH -> 4: ABSURD

func _ready():
	health = max_health
	
	for x in GROUPS:
		add_to_group(x)

func _physics_process(delta):
	# ANGLE SETTING
	if target != null:
		angleToTarget = (target.position - position).angle()
	
	velocityRaw = Vector2.ZERO # Replace with movement
	velocity = impulsion + velocityRaw
	move_and_slide()

func getOccupation():
	if pattern != "":
		hiveMind.forgetOccupation(pattern)
	
	for job in TROOP_OCCUPATIONS:
		var jobIndex = hiveMind.occupations.find(job)
		
		if jobIndex != -1:
			if hiveMind.amount[hiveMind.occupations.find(job)] < hiveMind.maxTroops[hiveMind.OCCUPATIONS.find(job)]:
				hiveMind.memorizeOccupation(job)
				pattern = job
				break
		else:
			hiveMind.memorizeOccupation(job)
			pattern = job
			break

# HANDLING DAMAGE
func damage(source: Node2D, amount:int, knockback):
	health -= amount
	# Add effects and shit
	Physics.impulse(self, source.moveangle + PI, knockback/knockbackResistance)
	if health <= 0:
		die()

# KILL INSTANCE
func die():
	queue_free()
