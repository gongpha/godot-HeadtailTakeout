extends Control
class_name RoundChooseANumberPlayer

var player : Player
var player_id : int

onready var character_node : CharacterControl = $character
onready var sign_node : TextureRect = $sign
onready var val_node : Label = $sign/val
onready var name_node : Label = $name
onready var balloon_node : TextureRect = $balloon

func _ready() :
	name_node.set_message_translation(false)
	val_node.set_message_translation(false)
	sign_node.hide()
	balloon_node.show()
	update_data()

func update_data() :
	if player :
		name_node.text = player.name
		character_node.player = player
		character_node.update_data()
		
		if player_id == GameMaster.player_id :
			name_node.add_color_override("font_color", Color(0.5, 1, 0.5))
		else :
			name_node.add_color_override("font_color", Color(1, 1, 1))
		
		if player.data != null :
			match player.data[2] :
				0 :
					# thinking
					sign_node.hide()
					balloon_node.show()
				1 :
					# finished. hide all
					sign_node.hide()
					balloon_node.hide()
				2 :
					# chosen. show number
					val_node.text = str(player.data[1])
					sign_node.show()
					balloon_node.hide()
				
		
#		if player.data != null :
#			if player.data[1] == -1 :
#				texture = close_tex
#				sign_node.hide()
#				character_node.hide()
#				face_node.hide()
#			else :
#				texture = open_tex
#				sign_node.show()
#				character_node.texture = player.icon_bg
#				face_node.texture = player.icon_fg
#				character_node.show()
#				face_node.show()
#				if GameMaster.current_round._get_head() == player_id :
#					in_node.texture = head_tex
#				elif GameMaster.current_round._get_tail() == player_id :
#					in_node.texture = tail_tex
#				else :
#					in_node.texture = pass_tex
