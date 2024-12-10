# PhysicsGenericOperations.gd
extends Object

static func impulse(node: Node2D ,angle, intensity):
	node.impulsion += Vector2(cos(angle) *intensity, sin(angle) *intensity)

# RETORNA A POSIÇÃO DE CONTATO ENTRE 1 OBJETO FÍSICO QUE SE MOVE E UM PROJÉTIL
static func predictContact(delta, target: Node2D, origin: Node2D, projectileSpeed):
	var TargDist = origin.global_position.distance_to(target.global_position)
	var TimeToTarg = TargDist/(projectileSpeed)
	var offset: Vector2 = target.velocity * Vector2(TimeToTarg,TimeToTarg) * delta
	
	return target.global_position + offset

static func spawnBullet(object, origin, pos, rot, type):
	var bullet = object.instantiate()
	bullet.position = pos
	bullet.moveangle = rot
	bullet.type = type
	bullet.start()
	origin.get_parent().add_child(bullet)

static func spawnParticle(type, origin: Node2D, rot):
	var particle = type.instantiate()
	particle.position = origin.position
	particle.rotation = rot
	origin.get_parent().add_child(particle)
