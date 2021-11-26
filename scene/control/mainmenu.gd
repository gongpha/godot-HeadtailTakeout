extends Control
class_name MainMenuControl

var selected_bot_count := -1
var selected_bot_count_button : Button

onready var hbox_count := $margin/center/vbox/hbox_count
onready var name_field := $margin/center/vbox/name_field
onready var ani := $ani

# local
var ui_ready := false # TRUE when animation playing finished

var button_list := []

const NUMLIST := [
	6, 8, 10, 16, 24, 32, 40, 48, 56, 64
]

func _ready() :
	# create number box list. ez
	for i in NUMLIST :
		var button := Button.new()
		button.text = str(i)
		button.toggle_mode = true
		button.connect("pressed", self, "_on_pressed_numbutton", [button])
		button_list.append(button)
		hbox_count.add_child(button)
		
	# init first
	selected_bot_count = NUMLIST[0]
	selected_bot_count_button = button_list[0]
	selected_bot_count_button.pressed = true
		
func _on_pressed_numbutton(node : Button) :
	if node == selected_bot_count_button :
		# selected. NO
		selected_bot_count_button.pressed = true
		return
		
	# UNSELECT PREV BUTTON 55555555555555555555555 (if it has)
	if selected_bot_count_button :
		selected_bot_count_button.pressed = false
		
	# new num selected. UPDATE DUDE
	selected_bot_count = int(node.text)
	selected_bot_count_button = node

func _on_start_pressed() :
	# STARTTTTTTTTTTT
	
	# check for security
	# must be even number
	if selected_bot_count % 2 != 0 or selected_bot_count < 0 or name_field.text == "" :
		return # no u cant
		
	GameMaster.lobbyinput_bot_count = selected_bot_count
	GameMaster.lobbyinput_name = name_field.text
	
	ani.play("go_play")
	
#####################################################

func go_play() :
	GameMaster.start_game()

#####################################################

# CHANGE LANG BUTTONNNNNNNNNNNNNN

func _on_lang_en_pressed() :
	TranslationServer.set_locale("en")

func _on_lang_th_pressed() :
	TranslationServer.set_locale("th")
