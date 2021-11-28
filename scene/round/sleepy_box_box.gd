extends Control
class_name RoundSleepyBoxBox

var player : Player
var player_id : int = -1

var close_tex := preload("res://resource/texture/box_close.atlastex")
var open_tex := preload("res://resource/texture/box_open.atlastex")
var head_tex := preload("res://resource/texture/head_symb.atlastex")
var tail_tex := preload("res://resource/texture/tail_symb.atlastex")
var pass_tex := preload("res://resource/texture/pass_symb.atlastex")

onready var box : TextureRect = $box
onready var label := $box/label
onready var sign_node := $box/sign
onready var in_node := $box/sign/in
onready var character_node := $box/character
onready var face_node := $box/character/face

func _ready() :
	sign_node.hide()
	character_node.hide()
	face_node.hide()
	update_data()

func update_data() :
	if player :
		label.text = player.name
		
		if player_id == GameMaster.player_id :
			label.add_color_override("font_color", Color(0.5, 1, 0.5))
		else :
			label.add_color_override("font_color", Color(1, 1, 1))
		
		if player.data != null :
			if player.data[1] == -1 :
				box.texture = close_tex
				sign_node.hide()
				character_node.hide()
				face_node.hide()
			else :
				box.texture = open_tex
				#sign_node.show()
				character_node.texture = player.icon_bg
				face_node.texture = player.icon_fg
				character_node.show()
				face_node.show()
				if GameMaster.current_round._get_head() == player_id :
					sign_node.show()
					in_node.texture = head_tex
				elif GameMaster.current_round._get_tail() == player_id :
					sign_node.show()
					in_node.texture = tail_tex
				else :
					sign_node.hide()
					#in_node.texture = pass_tex
					
				
			
