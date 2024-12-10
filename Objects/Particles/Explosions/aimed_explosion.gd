extends GPUParticles2D


# Called when the node enters the scene tree for the first time.
func _ready():
	
	restart() 
	$Smoke.restart()

# FOR SOME REASON THE LIGHT DOESNT DELETE PROPERLY, SO IM JUT MAKING IT DIMMER
func _process(delta):
	if $PointLight2D.energy > 0:
		$PointLight2D.energy -= delta * 16
	else:
		$PointLight2D.energy = 0

func _on_finished():
	$PointLight2D.enabled = false
	queue_free()
