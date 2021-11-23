extends PanelContainer
class_name PlayerList

var profile_box_scene : PackedScene = preload("res://scene/control/prefab/player_profile_box.tscn")

#onready var ani := $ani
onready var comp := $vbox/sc_comp/comp # comp list
onready var board := $vbox/sc_headtail/headtail # board list

func _ready() :
	pass

func fetch_comp_list() :
	# create player list as box list
	
	# clear old first (delete all)
	for c in comp.get_children() :
		c.free() # DELTEEEEEEEEEEEEEEEEEE
	
	for i in range(GameMaster.players.size()) :
		var box := profile_box_scene.instance() as PlayerProfileBox
		box.player = GameMaster.players[i]
		box.player_id = i
		comp.add_child(box)
		
func fetch_board_list() :
	# like above
	
	# clear old first (delete all)
	for c in board.get_children() :
		c.free() # DELTEEEEEEEEEEEEEEEEEE
	
	for i in range(GameMaster.players_board.size()) :
		var p : int = GameMaster.players_board[i]
		var box := profile_box_scene.instance() as PlayerProfileBox
		box.player = GameMaster.players[p]
		box.player_id = p
		box.board = true
		board.add_child(box)
		
func _board_updated() :
	fetch_board_list()
