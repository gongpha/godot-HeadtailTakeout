extends Node
# GameMaster Lite by kongfa waroros
# HEART OF THE GAME

var lobbyinput_bot_count : int = 10
var lobbyinput_name : String

var default_round_scenes := [
	preload("res://scene/round/sleepy_box.tscn")
]

# IN GAME
var players := [] # ADD WHEN CONFIRM PLAYING. items are Player class
var players_comp := [] # IN ROUND
var players_board := [] # IN BOARD
var player_current : Player # my player
var player_id : int = 0 # player id, normally 0
var current_round : RoundStage

signal board_updated()
signal changed_round()
signal round_end()

func start_game() :
	# START GAMEEEEEEEEEEEEEEEEEEEEEE (^O^)
	randomize() # random seed
	
	# add self
	player_current = Player.new()
	player_current.name = lobbyinput_name
	player_current.type = Player.Type.PLAYER
	players.append(player_current)
	players_comp.append(players.size() - 1)
	
	# get names list BY LANGUAGE
	# NOTEEEEEE : english names are bot1 bot2 bot3. becuase i have no idea
	var raw_name := TranslationServer.translate("##bot_names")
	var names : Array
	if raw_name == "##bot_names" :
		# fail to get name or use default names (bot1 bot2 bot3)
		pass
	else :
		# split names
		names = raw_name.split(" ")
	
	var botdefname_current_index : int = 1 # for naming bot1 bot2 bot3
	
	# generate bots by count
	# NAMES are UNIQUE DUDE
	for i in range(lobbyinput_bot_count) :
		var player := Player.new()
		if not names.empty() :
			var choosen := randi() % names.size() # random choose
			player.name = names[choosen]
			names.remove(choosen) # REMOVE. IS SELECTED THIS
			
		else :
			# USE default name
			player.name = "BOT" + str(botdefname_current_index)
			botdefname_current_index += 1
			
		# add players to list
		players.append(player)
		players_comp.append(players.size() - 1)
	
	get_tree().change_scene("res://scene/control/game_root.tscn")
	
func board_add_player(id : int, pos : int) :
	players_board.insert(pos, id)
	
	if not current_round._can_player_update_board() :
		return
	
	emit_signal("board_updated")

###############################################

func prepare_round() :
	if current_round :
		current_round.free() # delete round
		current_round = null
	# random and instance
	var choosed_round := default_round_scenes[randi() % default_round_scenes.size()].instance() as RoundStage
	
	current_round = choosed_round
	call_deferred("emit_signal", "changed_round")

func start_round() :
	if not current_round :
		return
		
	current_round.started = true
	current_round.start()

func end_round() :
	if not current_round :
		return
		
	current_round.started = false
	current_round.stop()
	
	for i in GameMaster.players_board :
		var p : Player = GameMaster.players[i]
		p.data = null
	
	GameMaster.players_board.clear()
	
	# REMOVE THAT FAILED PLAYERS HAHAHAHAAHAHHA
	var head_i : int = current_round._get_head()
	var tail_i : int = current_round._get_tail()
	var head_p : Player = players[current_round._get_head()]
	var tail_p : Player = players[current_round._get_tail()]
	head_p.eliminated = true
	tail_p.eliminated = true
	tail_p.eliminated_being_head = false
	players_comp.erase(head_i)
	players_comp.erase(tail_i)
	
	emit_signal("round_end")