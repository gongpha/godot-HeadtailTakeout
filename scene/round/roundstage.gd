extends Control
class_name RoundStage

# round stage is heart of the game round
# all gameplay or activity is here

var round_name := "" # use translation string eiei
var description := "" # use translation string eiei

var started : bool = false

# YOU CAN CREATE YOUR OWN ROUND HERE

# abstract function for compare from sort function
func _compare(a, b) -> bool :
	return a > b
	
# func to show data to gui
func _show_data(p : Player) -> String :
	return "@@@"
	
func _get_head() -> int :
	return -1
	
func _get_tail() -> int :
	return -1
	
func _can_player_update_board() -> bool :
	return true
	
func _put_player_to_board(id : int) :
	# find pos (Sort)
	var index_to_add : int = 0
	
	for p in GameMaster.players_board :
		var greater := _compare(GameMaster.players[id].data, GameMaster.players[p].data)
		if not greater :
			index_to_add += 1
			continue
		else :
			# ok sit here
			pass
	
	GameMaster.board_add_player(id, index_to_add)
	
#func _show_board_to_player(id : int) :
#	# id == -1 is all player

func start() :
	pass # nothing here
	
func stop() :
	pass # nothing here
