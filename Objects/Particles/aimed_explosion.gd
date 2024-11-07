extends CPUParticles2D

var velocity = Vector2()


func _ready():
	self.emitting = true

func _physics_process(delta):
	position += velocity
