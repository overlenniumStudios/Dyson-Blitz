extends Control

# Who's contained by the HP container?
var HPcontained: Array
var HPparticles: Array

# HP TARGET ( usually, the player! )
var HPtarget: Object # The target itself
var uncleName = "Spaceship" #The name of the uncle node that's called for the HP TARGET

# HPbar visual stuffs
var HPbarDecimal = 1.0
var HPbarDecimalLerp = 1.0
const HPbarLerpFactor = 0.075
const HPbarMaxWidth = 326

var HPbarTargPos: Vector2
const HPbarSnap = 1.5
var HPbarOffset = Vector2(0,0)
var cogSpeedModifier = 1.0

func _ready():
	HPbarTargPos = $Top/HPcontainer.position
	
	HPtarget = self.get_parent().get_parent().get_node(uncleName)
	
	# ARRAY WITH ALL ITEMS CONTAINED BY
	HPcontained = $Top/HPcontainer/Modular.get_children()
	HPparticles = $Top/HPcontainer/Particles.get_children()

	
	# CONNECT PLAYER SIGNAL TO UPDATEHPBAR FUNCTION
		# Makes it so that when the player sends a "health_changed" SIGNAL,
		# it executes the "updateHPbar" FUNCTION with the same parameters.
	HPtarget.connect("health_changed", updateHPbar)
	updateHPbar(HPtarget.maxHealth,HPtarget.maxHealth)
	

func _process(delta):
	$Top/HPcontainer/GearBig.rotation += delta        * cogSpeedModifier
	$Top/HPcontainer/GearSmol.rotation -= delta * 2.6 * cogSpeedModifier
	
	HPbarSnapBack(delta)
	
	if HPtarget:
		HPbarDecimalLerp = lerp( HPbarDecimalLerp, HPbarDecimal, HPbarLerpFactor)
		$Top/HPcontainer/Modular/HPlerp.size.x = (HPbarDecimalLerp * HPbarMaxWidth)
	else:
		print(self, "has not found any Player node")

func updateHPbar(newValue, maxValue):
	for particle in HPparticles:
		if randf() > 0.5:
			particle.emit()
	HPbarDecimal = float(newValue)/float(maxValue)
	$Top/HPcontainer/Modular/HP.size.x = ceil((HPbarDecimal * HPbarMaxWidth)/3)*3
	cogSpeedModifier += 6
	var offset_x = [-2, -1, 1, 2][randi() % 4]
	HPbarOffset = Vector2(offset_x * 5, 0)

func HPbarSnapBack(delta):
	$Top/HPcontainer.position = HPbarTargPos + HPbarOffset
	if cogSpeedModifier > 1.0:
		cogSpeedModifier -= delta * 12
	
	HPbarOffset += ((-HPbarOffset)* 5) * delta
