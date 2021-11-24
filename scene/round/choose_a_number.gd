extends RoundStage
class_name RoundChooseANumber

# ChooseANumber by kongfa waroros
# Choose a number. Dont Greater or least than other
# if someone same with someone. round restarts

onready var vbox_play := $center/vbox
onready var label := $center/vbox/label
onready var number := $center/vbox/number
onready var confirm := $center/vbox/confirm
onready var players := $margin/scroll/center/players

const MIN_NUMBER : int = -9223372036854775808 # DO NOT TRY IN C++ (32bit integer)
const MAX_NUMBER : int = 9223372036854775807 # DO NOT TRY IN C++ (32bit integer)

var player_scene : PackedScene = preload("res://scene/round/choose_a_number_player.tscn")
var players_list := []

var my_head : int = -1
var my_tail : int = -1

func _init() :
	round_name = "#Rchooseanum_name"
	description = "#Rchooseanum_desc"
	
func _ready() :
	# add boxes
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var pla : RoundChooseANumberPlayer = player_scene.instance()
		pla.player = p
		pla.player_id = i
		players.add_child(pla)
		players_list.append(pla)
		
	# check if CLIENT PLAYER failed. OTHERWISE you cannot do anything
	if GameMaster.player_current.eliminated :
		# you failed bruh. you cannot contorl
		vbox_play.queue_free()
