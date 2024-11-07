extends Camera2D

# CAMERA FOLLOWING
var target = "" # Reference to the target node (Spaceship)
var targetposition = Vector2(0, 0) # Position the camera will smoothly follow
var movefac = 0.18 # Factor that controls the smoothness of camera movement

#CAMERA ZOOMIN
var zoomr = 1
const ZOOM_MODIFIER = 0.33

# INITIALIZATION
# Called when the node enters the scene tree for the first time.
func _ready():
	target = self.get_parent().get_node("Spaceship")

# CAMERA UPDATE
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	targetposition = (target.position * 4 + target.mouse) / 5
	
	var distance = position.distance_to(target.position)
	
	
	#print(zoomr)
	var width_ratio = ((float(DisplayServer.window_get_size().x) /1280)) -1
	
	zoomr = (clamp(distance/-4000 +1, 0.5,1) * ZOOM_MODIFIER)
	
	zoom = Vector2(zoomr,zoomr)
	position = lerp(position, targetposition, movefac)