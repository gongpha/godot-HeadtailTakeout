extends Node2D
class_name RoundHammerMap

onready var sp : Node2D = $sp
onready var nav : Navigation2D = $nav

var sps : Array #PoolVector2Array <-- lack of features :(

func _ready() :
	# parse spawnpoints
	for n in sp.get_children() :
		var point := (n as Node2D).global_transform.origin
		sps.append(point)
	sp.free() # BYE BYE 5555555555555
	
	
