extends Control
class_name GameRoot

onready var ani := $ani
onready var list := $vbox/list as PlayerList
onready var centerboard := $centerboard as CenterContainer
onready var round_text := $centerboard/vbox/round_text as Label
onready var round_desc := $centerboard/vbox/panel_con/vbox/round_desc as Label
onready var root_stage := $vbox/root_stage as Control
onready var confirm_button := $centerboard/vbox/panel_con/vbox/confirm as Button

onready var vbox_e := $centerboard/vbox/panel_con/vbox/vbox_e as VBoxContainer
onready var head_el_box := $centerboard/vbox/panel_con/vbox/vbox_e/hbox/head as PlayerProfileBox
onready var tail_el_box := $centerboard/vbox/panel_con/vbox/vbox_e/hbox/tail as PlayerProfileBox
onready var bgm := $bgm as AudioStreamPlayer

#var round_ : RoundStage
var confirm_end_round : bool = false # TRUE if confirm button pressing will go next round
var skip_ani : bool = false

var bgms := [
	"res://resource/sound/mp3/20.mp3",
	"res://resource/sound/mp3/31.mp3"
]
var selected_bgm : AudioStream

func _ready() :
	GameMaster.connect("board_updated", list, "_board_updated")
	GameMaster.connect("changed_round", self, "_changed_round")
	GameMaster.connect("round_end", self, "_round_end")
	
	#GameMaster.game_root = self
	GameMaster.prepare_round()
	
	selected_bgm = load(bgms[randi() % bgms.size()])
	bgm.stream = selected_bgm
	bgm.play()

func _prepare_round(round_ : RoundStage) :
	centerboard.rect_pivot_offset = centerboard.rect_size / 2
	
	round_text.text = round_.round_name
	vbox_e.hide()
	round_desc.show()
	round_desc.text = round_.description
	
	root_stage.add_child(round_)
	root_stage.move_child(round_, 0)
	
	list.fetch_comp_list()
	list.fetch_board_list()
	
	ani.play("RESET")
	yield(ani, "animation_finished")
	ani.play("show_competitor_n_hide")
	yield(ani, "animation_finished")
	
	confirm_end_round = false
	
	if round_.description == "" :
		# empty ? just skip it
		skip_ani = true
		_on_confirm_pressed()
	else :
		skip_ani = false
		confirm_button.disabled = false
		ani.play("show_round_topic")

func _changed_round() :
	#ani.play("close_round")
	#yield(ani, "animation_finished")
	_prepare_round(GameMaster.current_round)
	
func _round_end() :
	centerboard.rect_pivot_offset = centerboard.rect_size / 2
	
	head_el_box.player_id = GameMaster.current_round._get_head()
	head_el_box.player = GameMaster.players[head_el_box.player_id]
	
	tail_el_box.player_id = GameMaster.current_round._get_tail()
	tail_el_box.player = GameMaster.players[tail_el_box.player_id]
	confirm_end_round = true
	
	head_el_box.update_info()
	tail_el_box.update_info()
	
	vbox_e.show()
	round_desc.hide()
	round_text.text = "#round_end"
	
	confirm_button.disabled = false
	ani.play("show_round_topic")
	


func _on_confirm_pressed() :
	confirm_button.disabled = true
	
	if confirm_end_round :
		# NEXT !
		GameMaster.prepare_round()
	else :
		if not skip_ani :
			ani.play("hide_round_topic")
			yield(ani, "animation_finished")
		GameMaster.start_round()
	
