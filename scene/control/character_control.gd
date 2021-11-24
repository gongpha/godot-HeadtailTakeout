extends TextureRect
class_name CharacterControl

onready var face : TextureRect = $face

var player : Player

func _ready() :
	update_data()
	
func update_data() :
	if player :
		texture = player.icon_bg
		face.texture = player.icon_fg
