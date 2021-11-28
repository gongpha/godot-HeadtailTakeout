extends PanelContainer
class_name RoundBalanceTheBallBar

onready var name_node : Label = $hbox/name
onready var bar : HSlider = $hbox/bar
onready var cpurand : Timer = $cpurand
onready var percent : Label = $percent

var add : float = 1.1
var cpu : bool = true

var input_add : float = 1.1

var player : Player
var player_id : int = -1
var collected : float = 0 

var control : bool setget set_control
var show_percent : bool setget set_show_percent

var highlight_panel := preload("res://resource/style/highlight_panel.stylebox")

func _ready() :
	name_node.set_message_translation(false)
	set_physics_process(false)
	percent.hide()
	update_data()
	
func set_control(con : bool) :
	control = con
	if con :
		input_add = 0
		bar.modulate = Color(1, 0.5, 0.5)
		collected = 0
	else :
		input_add = 1.1
		bar.modulate = Color(1, 1, 1)
		
func set_show_percent(show : bool) :
	if show :
		bar.modulate.a = 0.25
	else :
		bar.modulate.a = 1
	percent.text = "%.2f%%" % bar.value
	percent.visible = show
	
func update_data() :
	if player :
		name_node.text = player.name
		
		if player_id == GameMaster.player_id :
			add_stylebox_override("panel", highlight_panel)
			cpu = false
		else :
			add_stylebox_override("panel", null)
			cpu = true

func start_fly() :
	set_physics_process(true)

func _physics_process(delta : float) :
	var add_c : float = delta * abs(bar.value-50) * randf() * input_add * collected
	if bar.value > 50 :
		add -= add_c
	else :
		add += add_c
		
	collected += delta
		
	if bar.value == 0 or bar.value == 100 :
		add = -add
		
	# CPU
#	if cpu :
#		#if add < 10
#		if round(bar.value) == cpu_rand :
#			set_control(true)
#			cpu_rand = round(rand_range(-50, 50))
#		else :
#			set_control(bar.value < rand_range(0, 10) and bar.value > rand_range(0, -10))
	
	bar.value += add

func start_cpu() :
	# random like stupid
	if cpu :
		cpurand.start()
		
func stop_cpu() :
	if cpu :
		cpurand.stop()

func _on_cpurand_timeout() :
	set_control(not control)
	if GameMaster.is_player_rival() :
		# HEY. GO CONSTANT
		cpurand.wait_time = 0.5 + randf() * 0.01
	else :
		cpurand.wait_time = rand_range(0.1, 0.6)
	cpurand.start()
