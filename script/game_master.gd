extends Node
# GameMaster Lite by kongfa waroros
# HEART OF THE GAME

var lobbyinput_bot_count : int = 10
var lobbyinput_name : String
var lobbyinput_mode : int

var default_round_scenes := [
	#preload("res://scene/round/winner.tscn"),
	preload("res://scene/round/hammer.tscn"),
	preload("res://scene/round/balance_the_ball.tscn"),
	preload("res://scene/round/sleepy_box.tscn"),
	preload("res://scene/round/choose_a_number.tscn")
]

var default_character_faces := [
	preload("res://resource/texture/charac/char1.atlastex"),
	preload("res://resource/texture/charac/char2.atlastex"),
	preload("res://resource/texture/charac/char3.atlastex"),
	preload("res://resource/texture/charac/char4.atlastex"),
	preload("res://resource/texture/charac/char5.atlastex"),
	preload("res://resource/texture/charac/char6.atlastex"),
	preload("res://resource/texture/charac/char7.atlastex"),
	preload("res://resource/texture/charac/char8.atlastex")
]

var default_character_faces_happy := [
	preload("res://resource/texture/charac/char1happy.atlastex"),
	preload("res://resource/texture/charac/char2happy.atlastex"),
	preload("res://resource/texture/charac/char3happy.atlastex"),
	preload("res://resource/texture/charac/char4happy.atlastex"),
	preload("res://resource/texture/charac/char5happy.atlastex"),
	preload("res://resource/texture/charac/char6happy.atlastex"),
	preload("res://resource/texture/charac/char7happy.atlastex"),
	preload("res://resource/texture/charac/char8happy.atlastex")
]

var default_character_circles := [
	preload("res://resource/texture/charac/char_cir1.atlastex"),
	preload("res://resource/texture/charac/char_cir2.atlastex"),
	preload("res://resource/texture/charac/char_cir3.atlastex"),
	preload("res://resource/texture/charac/char_cir4.atlastex")
]

var default_character_circles_big := [
	preload("res://resource/texture/charac/char_cirbig1.atlastex"),
	preload("res://resource/texture/charac/char_cirbig2.atlastex"),
	preload("res://resource/texture/charac/char_cirbig3.atlastex"),
	preload("res://resource/texture/charac/char_cirbig4.atlastex")
]

var assigned_client_name : String # from mainmenu

# IN GAME
var players := [] # ADD WHEN CONFIRM PLAYING. items are Player class
var players_comp := [] # IN ROUND
var players_board := [] # IN BOARD
var player_current : Player # my player
var player_id : int = 0 # player id, normally 0
var current_round : RoundStage
var current_round_idx : int = -1

signal board_updated()
signal changed_round()
signal round_end()

func _generate_player() -> Player :
	var player := Player.new()
	# random player icon
	var bg_rand := randi() % default_character_circles.size()
	var fg_rand := randi() % default_character_faces.size()
	player.icon_bg = default_character_circles[bg_rand]
	player.icon_fg = default_character_faces[fg_rand]
	player.icon_bg_win = default_character_circles_big[bg_rand]
	player.icon_fg_win = default_character_faces_happy[fg_rand]
	player.icon_hue = randf()
	
	return player

func start_game() :
	# START GAMEEEEEEEEEEEEEEEEEEEEEE (^O^)
	randomize() # random seed
	
	# save that name in file
	var file := ConfigFile.new()
	file.set_value("player", "name", lobbyinput_name)
	file.set_value("player", "count", lobbyinput_bot_count)
	file.set_value("player", "mode", lobbyinput_mode)
	file.save("player.cfg")
	
	# add self
	player_current = _generate_player()
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
		var player := _generate_player()
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
	
func board_sort() :
	players_board.sort_custom(current_round, "_compare_id")
	
	if not current_round._can_player_update_board() :
		return
	
	emit_signal("board_updated")

###############################################

func prepare_round() :
	if current_round :
		current_round.free() # delete round
		current_round = null
		
	for i in GameMaster.players_board :
		var p : Player = GameMaster.players[i]
		p.data = null
		
	players_board.clear()
	
	var next_round_scene : PackedScene
	
	# there is one player here ?
	if players_comp.size() < 2 :
		next_round_scene = preload("res://scene/round/winner.tscn")
		
	else :
		# random and instance
		# AVOID repeating
		var choosed_round_idx : int = -1
		while true :
			choosed_round_idx = randi() % default_round_scenes.size()
			if current_round_idx != choosed_round_idx :
				break
			
		current_round_idx = choosed_round_idx
		next_round_scene = default_round_scenes[choosed_round_idx]
	var choosed_round := next_round_scene.instance() as RoundStage
	
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
	
	# REMOVE THAT FAILED PLAYERS HAHAHAHAAHAHHA
	var head_i : int = current_round._get_head()
	var tail_i : int = current_round._get_tail()
	var head_p : Player = players[head_i]
	var tail_p : Player = players[tail_i]
	head_p.eliminated = true
	tail_p.eliminated = true
	tail_p.eliminated_being_head = false
	players_comp.erase(head_i)
	players_comp.erase(tail_i)
	
	emit_signal("round_end")

static func get_sec_string(sec : int) -> String :
	return "%02d:%02d" % [floor(sec / 60), sec % 60]

func is_player_rival() :
	return lobbyinput_mode == 1 and GameMaster.players_comp.has(player_id)
