# Operations.gd
extends Object

# Cross product of two Vector2s
static func cross_product(a: Vector2, b: Vector2) -> float:
	return a.x * b.y - a.y * b.x

#static func get_nearestValue(list: Array, target):
#	pass

static func get_nearestNode(nodeList: Array, targetPos: Vector2) -> Node2D:
	var minDist = INF
	var closestNode = null
	
	if not nodeList.is_empty():
		for node in nodeList:
			var dist = targetPos.distance_squared_to(node.global_position)
			if dist < minDist:
				minDist = dist
				closestNode = node
	
	return closestNode

