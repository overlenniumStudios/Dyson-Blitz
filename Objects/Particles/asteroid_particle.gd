extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	restart() 

func _on_finished():
	queue_free()
