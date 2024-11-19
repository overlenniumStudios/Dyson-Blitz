extends Node2D

const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")

const OCCUPATIONS: Array = ["scout_orbit","scout_asteroid","end"]
var maxTroops: Array     = [0            ,16               ,0]

var occupations: Array     = []
@onready var amount: Array = []
var troops: Array          = []

func _ready():
	troops.resize(getPreceding_Max("end") + 1)
	troops.fill(null)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		print("HIVE MIND STATUS:")
		print(occupations)
		print(amount)
		print(troops)

func getPreceding(type):
	var precedingSlots = 0
	for index in range(0, occupations.find(type)):
		var current = occupations[index]
		precedingSlots += maxTroops[OCCUPATIONS.find(current)]
	return precedingSlots

func getPreceding_Max(type):
	var precedingSlots = 0
	for index in range(0, OCCUPATIONS.find(type)):
		var current = OCCUPATIONS[index]
		precedingSlots += maxTroops[OCCUPATIONS.find(current)]
	return precedingSlots



func memorizeOccupation(occupation: String, node):
	var globalJobIndex = OCCUPATIONS.find(occupation)
	
	if OCCUPATIONS.has(occupation):
		if occupations.find(occupation) == -1:
			occupations.append(occupation)
			amount.insert(occupations.find(occupation), 1)
		else:
			amount[occupations.find(occupation)] += 1
		
		print(occupations)
		print(amount)
	else:
		print('"', occupation, '" is not a valid occupation.')
	
	troops[(amount[occupations.find(occupation)]-1) + getPreceding(occupation)] = node

func forgetOccupation(occupation: String, node):
	
	troops[troops.find(node)] = null
	
	if occupations.has(occupation):
		if amount[occupations.find(occupation)] > 0:
			amount[occupations.find(occupation)] -= 1
		print(occupations)
		print(amount)
	else:
		print('"', occupation, '" is not an acctive occupation.')
	
