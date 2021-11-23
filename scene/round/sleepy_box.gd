extends RoundStage
class_name RoundSleepyBox

# SleepyBox by kongfa waroros
# Don't exit the box first or last
# Like original gameshow

onready var boxes := $margin/center/vbox/boxes
onready var inside := $inside
onready var exit_box := $center/exit_box

var box_scene : PackedScene = preload("res://scene/round/sleepy_box_box.tscn")
var boxes_list := []

var last_index : int = 0

var my_head : int = -1
var my_tail : int = -1

func _init() :
	round_name = "#Rsleepybox_name"
	description = "#Rsleepybox_desc"

func control_raise(from_id : int) :
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
	
func _get_head() -> int :
	return my_head
	
func _get_tail() -> int :
	return my_tail
	
func _show_data(p : Player) -> String :
	#var p : Player = GameMaster.players[id]
	return ""

func _on_exit_box_pressed() :
	if not started :
		return # not start yet
	# EXITTTTTTTTT
	control_raise(GameMaster.player_id)
	
func _ready() :
	# add boxes
	for i in GameMaster.players_comp :
		var p : Player = GameMaster.players[i]
		var box : RoundSleepyBoxBox = box_scene.instance()
		box.player = p
		boxes.add_child(box)
		boxes_list.append(box)
		
	# check if HUMAN PLAYER failed. OTHERWISE you cannot do anything
	if GameMaster.player_current.eliminated :
		# DELETE BUTTON HAHAHAHA
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
	
	# random how bot will out
	var median_list := [3]#[30, 60, 90]
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
			timer.connect("timeout", self, "control_raise", [i])
			add_child(timer)
			timer.start()
			
		# init data
		p.data = [timer, -1] # [exit yet, timer object, index]
	pass
