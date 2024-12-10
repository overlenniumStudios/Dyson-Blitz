extends GPUParticles2D

var startingPos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	startingPos = position
	
func emit():
	self.position = startingPos + Vector2(randi_range(-32,32),randi_range(-8,8))
	restart()
	$Smoke.restart()

# Called when the node finishes it's emission.
func _on_finished():
	pass
