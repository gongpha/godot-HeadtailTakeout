extends TextureRect
class_name RoundSleepyBoxBox

var player : Player

onready var label := $label

func _ready() :
	update_data()

func update_data() :
	if player :
		label.text = player.name
