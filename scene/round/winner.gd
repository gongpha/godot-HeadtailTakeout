extends RoundStage
class_name RoundWinner

# game over dude

var player : Player
var player_id : int

onready var winner_node : TextureRect = $center/vbox/hbox/winner
onready var face_node : TextureRect = $center/vbox/hbox/winner/face
onready var text_node : Label = $center/vbox/text
onready var cheer : AudioStreamPlayer = $cheer

func _get_status_of_player() -> String :
	var string := ._get_status_of_player()
	if string == "" :
		return "#winner_status"
	return string

func _ready() :
	if GameMaster.players_comp.empty() :
		return # impossible to reach this statement. protecc
		
	var winner_id : int = GameMaster.players_comp[0]
	var winner : Player = GameMaster.players[winner_id]
	
	if not winner :
		return # protecc
	
	winner_node.texture = winner.icon_bg_win
	face_node.texture = winner.icon_fg_win
	
	text_node.text = tr("#winner_header") % winner.name
	
func start() :
	cheer.play()
