extends TextureRect
class_name PlayerProfileBox

onready var name_node : Label = $name
onready var charac_node : CharacterControl = $character
onready var val_node : Label = $val

onready var margin_node : MarginContainer = $margin
onready var state_node : ColorRect = $margin/state
onready var state_label_node : Label = $margin/label

var grayscale_mat : ShaderMaterial = preload("res://resource/material/grayscale.tres")

# SET THIS BEFORE ENTER TREE DUDE
# BOK LAEW NAA
var player : Player
var player_id : int
export var board : bool = false
#var state : int = 0 # 1 = head, 2 = tail

func _ready() :
	name_node.set_message_translation(false) # DONT TRANSLATE PLAYER NAMES
	margin_node.hide()
	update_info()

func update_info() :
	if not player :
		# oof. error
		return
		
	# set his info
	name_node.text = player.name
	charac_node.player = player
	charac_node.update_data()
	
	if player_id == GameMaster.player_id :
		name_node.add_color_override("font_color", Color(0.5, 1, 0.5))
	else :
		name_node.add_color_override("font_color", Color(1, 1, 1))
	
	if board :
		val_node.show()
		val_node.text = GameMaster.current_round._show_data(player)
		
		if GameMaster.current_round._get_head() == player_id :
			margin_node.show()
			state_node.color = Color(0.66, 0, 0)
			state_label_node.text = "#head"
		elif GameMaster.current_round._get_tail() == player_id :
			margin_node.show()
			state_node.color = Color(0, 0, 0.66)
			state_label_node.text = "#tail"
		else :
			margin_node.hide()
	else :
		if player.eliminated :
			# YOU FAILED 55555555555
			margin_node.show()
			if player.eliminated_being_head :
				state_node.color = Color(0.66, 0, 0)
			else :
				state_node.color = Color(0, 0, 0.66)
			state_label_node.text = "#eliminated"
			charac_node.material = grayscale_mat
			charac_node.face.material = grayscale_mat
