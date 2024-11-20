extends Node2D

# HIVE MIND OCCUPATION MANAGEMENT
#	This script manages a "hive mind" system, tracking and organizing various occupations and their associated nodes. 
#	It uses arrays to store predefined occupation types, their maximum troop limits, and dynamically tracks current occupations, 
#	their quantities, and node allocations. Includes functions to calculate array indices for troop assignments, 
#	memorize new occupations, and forget existing ones. Useful for managing dynamic entities.

# DEPENDENCIES
const Operations = preload("res://GenericScripts/Operations.gd")
const Physics = preload("res://GenericScripts/PhysicsGeneric.gd")

# OCCUPATION ARRAY: DEFAULT VALUES (2 arrays)
const OCCUPATIONS: Array = ["scout_orbit","scout_asteroid","end"]
var maxTroops: Array     = [0            ,16               ,0]

# OCCUPATION ARRAY: MEMORY MODULE (3 arrays)
var occupations: Array     = []
@onready var amount: Array = []
var troops: Array          = []

func _ready():
	
	troops.resize(getPreceding_Max("end") + 1) # Change the size of the troops array to fit all possible occupations
	troops.fill(null) # Fill every occupation with "null", to signal it's avaliable for taking
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("ui_cancel"):
		print("HIVE MIND STATUS:")
		print(occupations)
		print(amount)
		print(troops)

# GET PRECEDING INDEXES
#	Returns the amount of indexes in the "troops" array that are 
#	reserved for other types of troops before the type that is called
func getPreceding(type):
	var precedingSlots = 0
	for index in range(0, occupations.find(type)):
		var current = occupations[index]
		precedingSlots += maxTroops[OCCUPATIONS.find(current)]
	return precedingSlots

# GET PRECEDING INDEXES
#	I dont know what I did here, let it be cause I might remember sometime
func getPreceding_Max(type):
	var precedingSlots = 0
	for index in range(0, OCCUPATIONS.find(type)):
		var current = OCCUPATIONS[index]
		precedingSlots += maxTroops[OCCUPATIONS.find(current)]
	return precedingSlots

# MEMORIZE OCCUPATION
#	Append a specific occupation for the hive mind to keep track of in its
#	occupation memorization array.
func memorizeOccupation(occupation: String, node):
	var globalJobIndex = OCCUPATIONS.find(occupation)
	
	if OCCUPATIONS.has(occupation):
		if occupations.find(occupation) == -1:
			occupations.append(occupation)
			amount.insert(occupations.find(occupation), 1)
		else:
			amount[occupations.find(occupation)] += 1
		
	else:
		print('"', occupation, '" is not a valid occupation.')
	
	troops[(amount[occupations.find(occupation)]-1) + getPreceding(occupation)] = node

# MEMORIZE OCCUPATION
#	Append a specific occupation for the hive mind to forget about in its
#	occupation memorization array.
func forgetOccupation(occupation: String, node):
	
	troops[troops.find(node)] = null
	
	if occupations.has(occupation):
		if amount[occupations.find(occupation)] > 0:
			amount[occupations.find(occupation)] -= 1
	
	else:
		print('"', occupation, '" is not an active occupation.')
	
