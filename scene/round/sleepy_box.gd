extends RoundStage
class_name RoundSleepyBox

# SleepyBox by kongfa waroros
# Don't exit the box first or last
# Like original gameshow

onready var boxes := $margin/scroll/center/boxes
onready var inside := $inside
onready var exit_box := $center/vbox/exit_box
onready var time_node := $center/vbox/time
onready var sectimer := $sectimer

var box_scene : PackedScene = preload("res://scene/round/sleepy_box_box.tscn")
var boxes_list := []

var last_index : int = 0
var sec : int = 0

var my_head : int = -1
var my_tail : int = -1

func _init() :
	round_name = "#Rsleepybox_name"
	description = "#Rsleepybox_desc"
	
func get_sec_string(sec : int) :
	return "%02d:%02d" % [floor(sec / 60), sec % 60]
	
func update_time_text() :
	time_node.text = get_sec_string(sec)

func control_raise(from_id : int, pp = null, tt = null) :
	if my_head == -1 :
		# YOU ARE HEAD 55555555555555555555555555555555555
		my_head = from_id
	
	# check if player almost go out
	if last_index == GameMaster.players_comp.size() - 1 :
		# YOU ARE TAIL 55555555555555555555555555555555555
		my_tail = from_id
		
	# call to tell this player GET OUT
	var p : Player = GameMaster.players[from_id]
	p.data[1] = last_index # SET INDEX DATA
	p.data[2] = sec
	_put_player_to_board(from_id)
	last_index += 1
	
	# if he are you. stop showing dark overlay
	if GameMaster.player_id == from_id :
		inside.hide()
		exit_box.disabled = true
		
	# delete timer (if has)
	var timer : Timer = p.data[0]
	if timer :
		timer.queue_free()
		p.data[0] = null
	
	_update_boxes()
	
	if last_index == GameMaster.players_comp.size() - 1 :
		# hey everyone came out dude
		for i in GameMaster.players_comp :
			p = GameMaster.players[i]
			if p.data[1] == -1 :
				# OH YOU ARE. YOU TAIL
				my_tail = i
				control_raise(i)
				GameMaster.end_round()
				break
	
func _put_player_to_board(id : int) :
	GameMaster.board_add_player(id, last_index)
	
func _can_player_update_board() -> bool :
	if not GameMaster.player_current.eliminated :
		if GameMaster.player_current.data[1] == -1 :
			return false
	return true
	
func _get_status_of_player() -> String :
	var string := ._get_status_of_player()
	if string == "" :
		return "#Rsleepybox_status"
	return string
	
func _get_head() -> int :
	return my_head
	
func _get_tail() -> int :
	return my_tail
	
func _show_data(p : Player) -> String :
	#var p : Player = GameMaster.players[id]
	return get_sec_string(p.data[2])

func _on_exit_box_pressed() :
	if not started :
		return # not start yet
	# EXITTTTTTTTT
	control_raise(GameMaster.player_id)
	
func _ready() :
	update_time_text()
	
	# add boxes
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var box : RoundSleepyBoxBox = box_scene.instance()
		box.player = p
		box.player_id = i
		boxes.add_child(box)
		boxes_list.append(box)
		
	# check if CLIENT PLAYER failed. OTHERWISE you cannot do anything
	if GameMaster.player_current.eliminated :
		# DELETE BUTTON HAHAHAHA AND NO DARK OVERLAY
		inside.hide()
		exit_box.queue_free()
		
		
func _update_boxes() :
	# is player exit yet. OTHERWISE YOU CANNOT SEE or you are failed
	if not _can_player_update_board() :
		return
		
	for b in boxes_list :
		b.update_data()

func start() :
	# start cpu timing
	# THIS IS HOW CPU WORK
	sectimer.start()
	
	# random how bot will out
	var median_list := [3]#[15, 30, 45, 60]
	median_list.shuffle()
	var median_second := median_list[0] as int
	
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		
		var timer : Timer
			
		if p.type == Player.Type.BOT :
			# if this is bot. Make timer
			timer = Timer.new()
			# add more time for reality (+RAND*median) maybe faster or slower
			timer.wait_time = median_second + (randf() * 2 - 1) * median_second
			timer.one_shot = true
			timer.connect("timeout", self, "control_raise", [i, p, timer])
			add_child(timer)
			timer.start()
			
		# init data
		p.data = [timer, -1, -1] # [exit yet, timer object, index]
	pass

func stop() :
	sectimer.stop()

func _on_sectimer_timeout() :
	sec += 1
	update_time_text()
