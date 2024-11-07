extends CharacterBody2D

# CONSTS
#const BulletScene = preload("PATH_TO_PROJECTILES") #add as many as needed
const GROUPS = ["enemies","SPECIFIC_ENEMY_GROUP","damageable"]

# TARGETING
var target: Node2D

# MOVEMENT
var angleToTarget = 0

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

# HANDLING DAMAGE
func damage(source, amount:int, knockback):
	health -= amount
	# Add effects and shit
	if health <= 0:
		die()

# KILL INSTANCE
func die():
	queue_free()
