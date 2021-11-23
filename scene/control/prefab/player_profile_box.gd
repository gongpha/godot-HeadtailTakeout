extends Control
class_name PlayerProfileBox

onready var name_node : Label = $hbox/vbox/name
onready var pic_node : TextureRect = $hbox/pic
onready var val_node : Label = $hbox/vbox/val

onready var state_node : ColorRect = $profile/state
onready var state_label_node : Label = $profile/state/label

# SET THIS BEFORE ENTER TREE DUDE
# BOK LAEW NAA
var player : Player
var player_id : int
export var board : bool = false
#var state : int = 0 # 1 = head, 2 = tail

func _ready() :
	update_info()

func update_info() :
	if not player :
		# oof. error
		return
		
	# set his info
	name_node.text = player.name
	pic_node.texture = player.icon
	
	if board :
		val_node.show()
		val_node.text = GameMaster.current_round._show_data(player)
		
		if GameMaster.current_round._get_head() == player_id :
			state_node.show()
			state_node.color = Color(0.66, 0, 0)
			state_label_node.text = "#head"
		elif GameMaster.current_round._get_tail() == player_id :
			state_node.show()
			state_node.color = Color(0, 0, 0.66)
			state_label_node.text = "#tail"
		else :
			state_node.hide()
	else :
		if player.eliminated :
			# YOU FAILED 55555555555
			state_node.show()
			if player.eliminated_being_head :
				state_node.color = Color(0.66, 0, 0)
			else :
				state_node.color = Color(0, 0, 0.66)
			state_label_node.text = "#eliminated"
