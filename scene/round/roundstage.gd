extends Control
class_name RoundStage

# HUAJAI OF GAME
# round stage is heart of the game round
# all gameplay or activity is here

var round_name := "" # use translation string eiei
var description := "" # use translation string eiei

var started : bool = false

# YOU CAN CREATE YOUR OWN ROUND HERE

# abstract function for compare from sort function
func _compare(a, b) -> bool :
	return a.data > b.data
	
func _compare_id(a, b) -> bool :
	return GameMaster.players[a].data > GameMaster.players[b].data
	
# func to show data to gui
func _show_data(p : Player) -> String :
	return "@@@"
	
func _get_head() -> int :
	return -1
	
func _get_tail() -> int :
	return -1
	
# can player update the board data ?
func _can_player_update_board() -> bool :
	return true
	
# get status of player. R U PASSING SON
func _get_status_of_player() -> String :
	if GameMaster.player_current.eliminated : # if player failed
		return "#status_eliminated"
	if GameMaster.player_id in GameMaster.players_comp : # if player playing
		if GameMaster.current_round._get_head() == GameMaster.player_id :
			return "#status_eliminated_head"
		elif GameMaster.current_round._get_tail() == GameMaster.player_id :
			return "#status_eliminated_tail"
		elif GameMaster.player_id in GameMaster.players_board :
			return "#status_passed"
	return ""
	
func _sort_board() :
	GameMaster.board_sort()
	
func _put_player_to_board(id : int) :
	# find pos (Sort)
	var index_to_add : int = 0
	
	for p in GameMaster.players_board :
		var greater := _compare(GameMaster.players[id], GameMaster.players[p])
		if not greater :
			index_to_add += 1
			continue
		else :
			# ok sit here
			pass
	
	GameMaster.board_add_player(id, index_to_add)
	
func is_board_unreliable() -> bool :
	return false
#func _show_board_to_player(id : int) :
#	# id == -1 is all player

func start() :
	pass # nothing here
	
func stop() :
	pass # nothing here
