# PhysicsGenericOperations.gd
extends Object

static func impulse(node: Node2D ,angle, intensity):
	node.impulsion += Vector2(cos(angle) *intensity, sin(angle) *intensity)

# O ALGORITMO TA QUEBRADO DESCULPA D:
static func predictContact(target: Node2D, origin: Node2D, projectileSpeed):
	return target.global_position
	#return target.global_position - target.velocity * (origin.global_position.distance_to(target.global_position)/(projectileSpeed - target.velocity.length()))

static func spawnBullet(object, origin, pos, rot, type):
	var bullet = object.instantiate()
	bullet.position = pos
	bullet.moveangle = rot
	bullet.type = type
	bullet.start()
	origin.get_parent().add_child(bullet)
