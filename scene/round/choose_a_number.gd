extends RoundStage
class_name RoundChooseANumber

# ChooseANumber by kongfa waroros
# Choose a number. Dont Greater or least than other
# if someone same with someone. round restarts

onready var vbox_play := $center/vbox
onready var label := $center/vbox/label
onready var number := $center/vbox/number
onready var confirm := $center/vbox/confirm
onready var head := $center/vbox/head
onready var players := $margin/scroll/center/players
onready var anitime := $anitime
onready var show := $show

const MIN_NUMBER : int = -1000000
const MAX_NUMBER : int = 1000000

enum AniTimeMethod {
	GOING_TO_SHOW_SIGN
	PUT_IN_BOARD
}
var anitime_method : int
var anitime_current_id : int # hey you. show yo sign

var player_scene : PackedScene = preload("res://scene/round/choose_a_number_player.tscn")
var players_list := []

var last_index : int = 0
var number_choosing : bool = true

var min_id : int = -1
var min_val : int = MAX_NUMBER
var max_val : int = MIN_NUMBER
var max_id : int = -1

func _init() :
	round_name = "#Rchooseanum_name"
	description = "#Rchooseanum_desc"
	
func _ready() :
	number.set_min(MIN_NUMBER)
	number.set_max(MAX_NUMBER)
	head.hide()
	
	# add players
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
		vbox_play.hide()
	
func _show_data(p : Player) -> String :
	#var p : Player = GameMaster.players[id]
	return str(p.data[1])
	
func _update_characters() :
	for p in players_list :
		p.update_data()
		
func _get_status_of_player() -> String :
	var string := ._get_status_of_player()
	if string == "" :
		if number_choosing :
			return "#Rchooseanum_status"
		else :
			return "#Rchooseanum_wait"
	return string
		
func _get_head() -> int :
	return max_id
	
func _get_tail() -> int :
	return min_id
		
func _judge() :
	# let check their numbers
	var num_stack := []
	number_choosing = false
	
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var num : int = p.data[1]
		
		if num_stack.has(num) :
			# already HAS. DUPLICATING DETECTED
			# RESTART !!!!!!!!!
			head.text = "#Rchooseanum_duplicate"
			head.show()
			start()
			return
		else :
			num_stack.append(num)
			
	# ok let check with animation
	head.text = "#Rchooseanum_checking"
	head.show()
	
	
	anitime_method = 0
	anitime_current_id = 0
	anitime.start()
		
func control_chosen(from_id : int, in_number : int) :
	# SOMEONE COMPLETE CHOOSEN NUMBER. TAI NAE NAE
	var p : Player = GameMaster.players[from_id]
	
	p.data[1] = in_number
	p.data[2] = 1
	last_index += 1
	
	# delete timer (if has)
	var timer : Timer = p.data[0]
	if timer :
		timer.queue_free()
		p.data[0] = null
		
	# if he are you. disable all input
	if GameMaster.player_id == from_id :
		confirm.disabled = true
		number.editable = false
		
	if last_index == GameMaster.players_comp.size() :
		# last person completed !
		number_choosing = true
		_judge()
		
	_update_characters()
	
# for randoming from cpu
# players usually random number at 0 - 10000
var trend : PoolVector2Array = [
	Vector2(10, 99),
	Vector2(5, 99),
	Vector2(100, 999),
	Vector2(50, 999),
	Vector2(1000, 9999),
	Vector2(500, 9999),
	Vector2(-1000, 1000), # rare
]

var trend_hard : PoolVector2Array = [
	Vector2(100000, 1000000),
	Vector2(10000, 100000),
	Vector2(1000, 10000),
]
		
func start() :
	last_index = 0
	number_choosing = true
	
	# inputs
	if not GameMaster.player_current.eliminated :
		confirm.disabled = false
		number.editable = true
		
	# for hard mode
	var big_trend : int
	if GameMaster.is_player_rival() :
		var ch_vec : Vector2 = trend_hard[randi() % trend_hard.size()]
		big_trend = rand_range(ch_vec.x, ch_vec.y)
		if randi() % 4 == 0 :
			# sometimes, ITS NEGATIVE
			big_trend *= -1
	
	# random THINK SEC
	# delay lol
	
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		
		var thinksec : float
		if not GameMaster.is_player_rival() :
			thinksec = rand_range(1, 10)
		else :
			thinksec = rand_range(0.6, 1) # THINK FASS
		var timer : Timer
		var rand : int = -1
			
		if p.type == Player.Type.BOT :
			# if this is bot. Make timer
			timer = Timer.new()
			# add more time for reality (+RAND*median) maybe faster or slower
			timer.wait_time = thinksec
			timer.one_shot = true
			
			# GENERATE NOW HAHAHA
			# dont generate between min and max
			# ITS TOO LARGE AREA
			# Just make trend
			var number : int
			if not GameMaster.is_player_rival() :
				var ch_vec : Vector2 = trend[randi() % trend.size()]
				number = rand_range(ch_vec.x, ch_vec.y)
			else :
				# HEY HEY, GO MILLION. LET BRUH
				number = big_trend + (randf() * 2 - 1) * big_trend * 0.25
			timer.connect("timeout", self, "control_chosen", [i, number])
			add_child(timer)
			timer.start()
			
		# init data
		p.data = [timer, rand, 0] # [timer, number, state*]
		# * 0 = think, 1 = finished, 2 = show
	pass


func _on_confirm_pressed() :
	if not started :
		return # not start yet
		
	# RAISE !
	control_chosen(GameMaster.player_id, number.value)


func _on_anitime_timeout() :
	var i : int = GameMaster.players_comp[anitime_current_id]
	var p : Player = GameMaster.players[i]
	
	match anitime_method :
		AniTimeMethod.GOING_TO_SHOW_SIGN :
			# show you SIGN
			p.data[2] = 2
			show.play()
			anitime_method = AniTimeMethod.PUT_IN_BOARD
			anitime.start()
			
		AniTimeMethod.PUT_IN_BOARD :
			# put in board
			var in_number : int = p.data[1]
			
			# compare now
			if in_number < min_val :
				min_id = i
				min_val = in_number
			if in_number > max_val :
				max_id = i
				max_val = in_number
			
			_put_player_to_board(i)
			
			anitime_method = AniTimeMethod.GOING_TO_SHOW_SIGN
			anitime_current_id += 1
			
			if last_index == anitime_current_id :
				# end
				GameMaster.end_round()
			else :
				anitime.start()
	
	_update_characters()
