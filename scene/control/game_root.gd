extends Control
class_name GameRoot

onready var ani := $ani
onready var list := $vbox/list as PlayerList
onready var centerboard := $centerboard as CenterContainer
onready var round_text := $centerboard/vbox/round_text as Label
onready var round_desc := $centerboard/vbox/panel_con/vbox/round_desc as Label

onready var vbox_e := $centerboard/vbox/panel_con/vbox/vbox_e as VBoxContainer
onready var head_el_box := $centerboard/vbox/panel_con/vbox/vbox_e/head as PlayerProfileBox
onready var tail_el_box := $centerboard/vbox/panel_con/vbox/vbox_e/tail as PlayerProfileBox

#var round_ : RoundStage
var confirm_end_round : bool = false # TRUE if confirm button pressing will go next round

func _ready() :
	GameMaster.connect("board_updated", list, "_board_updated")
	GameMaster.connect("changed_round", self, "_changed_round")
	GameMaster.connect("round_end", self, "_round_end")
	
	#GameMaster.game_root = self
	GameMaster.prepare_round()

func _prepare_round(round_ : RoundStage) :
	centerboard.rect_pivot_offset = centerboard.rect_size / 2
	
	round_text.text = round_.round_name
	vbox_e.hide()
	round_desc.show()
	round_desc.text = round_.description
	
	add_child(round_)
	move_child(round_, 0)
	
	list.fetch_comp_list()
	list.fetch_board_list()
	
	ani.play("RESET")
	yield(ani, "animation_finished")
	ani.play("show_competitor_n_hide")
	yield(ani, "animation_finished")
	ani.play("show_round_topic")
	
	confirm_end_round = false

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
	
	
	ani.play("show_round_topic")
	


func _on_confirm_pressed() :
	if confirm_end_round :
		# NEXT !
		GameMaster.prepare_round()
	else :
		ani.play("hide_round_topic")
		yield(ani, "animation_finished")
		GameMaster.start_round()
	
