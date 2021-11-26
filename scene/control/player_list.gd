extends PanelContainer
class_name PlayerList

var profile_box_scene : PackedScene = preload("res://scene/control/prefab/player_profile_box.tscn")

#onready var ani := $ani
onready var comp := $vbox/sc_comp/comp # comp list
onready var board := $vbox/sc_headtail/headtail # board list
onready var status_text := $vbox/hbox/status # status textfor show your current state

onready var all_label := $vbox/hbox/all
onready var comp_label := $vbox/hbox/comp
onready var eli_label := $vbox/hbox/eli

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
		
	all_label.text = tr("#list_all") % GameMaster.players.size()
	comp_label.text = tr("#list_comp") % GameMaster.players_comp.size()
	eli_label.text = tr("#list_eli") % (GameMaster.players.size() - GameMaster.players_comp.size())
		
func fetch_board_list() :
	# like above
	
	# clear old first (delete all)
	for c in board.get_children() :
		c.free() # DELTEEEEEEEEEEEEEEEEEE
	
	for i in GameMaster.players_board :
		var box := profile_box_scene.instance() as PlayerProfileBox
		box.player = GameMaster.players[i]
		box.player_id = i
		box.board = true
		board.add_child(box)
		
	status_text.text = GameMaster.current_round._get_status_of_player()
		
func _board_updated() :
	fetch_board_list()
