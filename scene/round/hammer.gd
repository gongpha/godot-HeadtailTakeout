extends RoundStage
class_name RoundHammer

# Hammer by kongfa waroros
# hit everyone lol
# who had most or least hit count, die

onready var vc : ViewportContainer = $vc
onready var vp : Viewport = $vc/vp
onready var map : RoundHammerMap = $vc/vp/map
onready var time : Label = $time
onready var countdown : Timer = $countdown
onready var inputs : Label = $inputs

var player_scene : PackedScene = preload("res://scene/round/hammer_player.tscn")

var players_list := []
var my_player : RoundHammerPlayer

const MIN_NUMBER : int = -1000000
const MAX_NUMBER : int = 1000000

var min_id : int = -1
var max_id : int = -1

var timeleft : int = 60

func _init() :
	round_name = "#Rhammer_name"
	description = "#Rhammer_desc"

func _ready() :
	_update_time()
	
	# get spawnpoints
	var available_sps := map.sps.duplicate()
	
	# make players
	for i in GameMaster.players_comp :
		
		
		var p : Player = GameMaster.players[i]
		var pla : RoundHammerPlayer = player_scene.instance()
		
		# set data
		p.data = 0 # hit count
		
		pla.player = p
		pla.player_id = i
		pla.at_map = map
		pla.connect("hit", self, "_hit")
		map.add_child(pla)
		players_list.append(pla)
		# choose sp
		var sp := available_sps[randi() % available_sps.size()] as Vector2
		pla.global_transform.origin = sp
		
		if i == GameMaster.player_id :
			# he's mine
			my_player = pla
		
	if my_player :
		my_player.cam.current = true
		my_player.cpu = false
		var listener := Listener2D.new()
		my_player.add_child(listener)
		listener.make_current()
	else :
		# spec random
		players_list[randi() % players_list.size()].cam.current = true
		inputs.queue_free()
			
func start() :
	countdown.start()
	
	for p in players_list :
		p.set_physics_process(true)
		p.fetch_target()
		
func _show_data(p : Player) -> String :
	return str(p.data)

func _hit(to : Player, to_id : int) :
	to.data += 1 # ++
	
	var min_data : int = GameMaster.players[min_id].data
	var max_data : int = GameMaster.players[max_id].data
	
	if to.data <= min_data or min_id == -1 :
		min_id = to_id
	if to.data >= max_data or max_id == -1 :
		max_id = to_id
	
	#countdown.paused = (to.data == min_data or min_id == -1) or (to.data == max_data or max_id == -1)

	if not GameMaster.players_board.has(to_id) :
		# new here ? come here dud
		_put_player_to_board(to_id)
	else :
		_sort_board()
	
	# force update
	GameMaster.emit_signal("board_updated")

func is_board_unreliable() -> bool :
	return true
	
func _get_head() -> int :
	return max_id
	
func _get_tail() -> int :
	return min_id

func _update_time() :
	time.text = GameMaster.get_sec_string(timeleft)

func _on_countdown_timeout() :
	timeleft -= 1
	_update_time()
	
	if timeleft == 0 :
		for p in players_list :
			p.set_physics_process(false)
		
		GameMaster.end_round()
		return
	countdown.start()
