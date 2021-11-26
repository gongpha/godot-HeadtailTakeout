extends RoundStage
class_name RoundBalanceTheBall

# BalanceTheBall by kongfa waroros
# Keep pressing a button to push the ball.
# KEEP BALANCE AS POSSIBLE (use float)

var judging := false

onready var anitime : Timer = $anitime
onready var time_node : Label = $vbox/time
onready var grid_bars : GridContainer = $vbox/scroll/grid_bars
onready var input_button : Button = $vbox/input
onready var countdown : Timer = $countdown

var anitime_method : int
var anitime_current_id : int

var bar_scene : PackedScene = preload("res://scene/round/ball_bar.tscn")
var bars_list := []
var client_bar : RoundBalanceTheBallBar # my bar

var number_choosing : bool = true

var min_id : int = -1
var min_val : float = 101
var max_val : float = -101
var max_id : int = -1

var input_push : bool = false

enum AniTimeMethod {
	GOING_TO_SHOW_VAL
	PUT_IN_BOARD
}

var timeleft : int

func _init() :
	round_name = "#Rbalancetheball_name"
	description = "#Rbalancetheball_desc"
	
func _ready() :
	# random timer
	var clock := [10, 20, 30]
	clock.shuffle()
	timeleft = clock[0]
	
	_update_timer_text()
	
	# add players
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var bar : RoundBalanceTheBallBar = bar_scene.instance()
		
		if i == GameMaster.player_id :
			client_bar = bar
		
		bar.player = p
		bar.player_id = i
		p.data = bar
		grid_bars.add_child(bar)
		bars_list.append(bar)
		
	# check if CLIENT PLAYER failed. OTHERWISE you cannot do anything
	if GameMaster.player_current.eliminated :
		# you failed bruh. you cannot contorl
		input_button.hide()
	
func _show_data(p : Player) -> String :
	return "%.2f%%" % p.data.bar.value
		
func _get_status_of_player() -> String :
	var string := ._get_status_of_player()
	if string == "" :
		if judging :
			return "#Rbalancetheball_checking"
		else :
			return "#Rbalancetheball_status"
	return string
		
func _get_head() -> int :
	return max_id
	
func _get_tail() -> int :
	return min_id
		
func start() :
	# start cpu timing (for realistic)
	# THIS IS HOW CPU WORK
	
	# random THINK SEC
	# delay lol
	
	input_button.disabled = false
	countdown.start()
	
	for b in bars_list :
		b.set_physics_process(true) # start animating
		b.start_cpu()

#func _on_anitime_timeout() :
#	var i : int = GameMaster.players_comp[anitime_current_id]
#	var p : Player = GameMaster.players[i]
#
#	match anitime_method :
#		AniTimeMethod.GOING_TO_SHOW_SIGN :
#			# show you SIGN
#			p.data[2] = 2
#			anitime_method = AniTimeMethod.PUT_IN_BOARD
#			anitime.start()
#
#		AniTimeMethod.PUT_IN_BOARD :
#			# put in board
#			var in_number : int = p.data[1]
#
#			# compare now
#			if in_number < min_val :
#				min_id = i
#				min_val = in_number
#			if in_number > max_val :
#				max_id = i
#				max_val = in_number
#
#			_put_player_to_board(i)
#
#			anitime_method = AniTimeMethod.GOING_TO_SHOW_SIGN
#			anitime_current_id += 1
#
#			if last_index == anitime_current_id :
#				# end
#				GameMaster.end_round()
#			else :
#				anitime.start()
#
#	_update_characters()

func _judge() :
	judging = true
	
	var num_stack := []
	
	# check first
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var num : float = p.data.bar.value
		
		if num_stack.has(num) :
			# oops, overtime
			timeleft += 3
			start()
			return
		else :
			num_stack.append(num)
	
	# OK, stop all
	for b in bars_list :
		b.set_physics_process(false)
		b.stop_cpu()
		b.control = false
	
	input_button.disabled = true
		
	anitime_method = 0
	anitime_current_id = 0
	anitime.start()
	
func _update_bars() :
	for b in bars_list :
		b.update_data()

func _on_input_button_down() :
	input_push = true
	if client_bar :
		client_bar.control = true
	
func _on_input_button_up() :
	input_push = false
	if client_bar :
		client_bar.control = false

func _update_timer_text() :
	time_node.text = GameMaster.get_sec_string(timeleft)

func _on_countdown_timeout() :
	timeleft -= 1
	if timeleft == 0 :
		_judge()
	else :
		countdown.start()
	_update_timer_text()
	
func _compare(a, b) -> bool :
	return a.bar.value > b.bar.value
	
func _on_anitime_timeout() :
	var i : int = GameMaster.players_comp[anitime_current_id]
	var p : Player = GameMaster.players[i]
	
	match anitime_method :
		AniTimeMethod.GOING_TO_SHOW_VAL :
			# show you SIGN
			p.data.set_show_percent(true)
			anitime_method = AniTimeMethod.PUT_IN_BOARD
			anitime.start()
			
		AniTimeMethod.PUT_IN_BOARD :
			# put in board
			var in_number : float = p.data.bar.value # get percent of the bar
			
			# compare now
			if in_number < min_val :
				min_id = i
				min_val = in_number
			if in_number > max_val :
				max_id = i
				max_val = in_number
			
			_put_player_to_board(i)
			
			anitime_method = AniTimeMethod.GOING_TO_SHOW_VAL
			anitime_current_id += 1
			
			if GameMaster.players_comp.size() == anitime_current_id :
				# end
				GameMaster.end_round()
			else :
				anitime.start()
	
	_update_bars()
