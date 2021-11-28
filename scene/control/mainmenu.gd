extends Control
class_name MainMenuControl

var selected_bot_count := -1
var selected_mode := -1
var selected_bot_count_button : Button

var settings_lang : String = "en"

onready var hbox_count := $margin/center/vbox/hbox_count
onready var name_field := $margin/center/vbox/name_field
onready var normal_button := $margin/center/vbox/diff/normal
onready var hard_button := $margin/center/vbox/diff/hard
onready var ani := $ani

# local
var ui_ready := false # TRUE when animation playing finished

var button_list := []

const NUMLIST := [
	6, 8, 10, 16, 24, 32, 40, 48, 56, 64
]

func _ready() :
	# load settings
	var file := ConfigFile.new()
	var err := file.load("settings.cfg")
	if err != OK :
		pass # file isn't exist. use default
	else :
		settings_lang = file.get_value("settings", "lang", settings_lang)
		TranslationServer.set_locale(settings_lang)
		
	var loaded_player_count : int = -1
	var loaded_mode : int = -1
	var custom : bool = false
	# load name from file
	file = ConfigFile.new()
	err = file.load("player.cfg")
	if err != OK :
		pass # file isn't exist. ignore
	else :
		# !!! special
		custom = file.get_value("player", "custom", false)
		
		name_field.text = file.get_value("player", "name", "Player")
		loaded_player_count = file.get_value("player", "count", 6)
		loaded_mode = file.get_value("player", "mode", 0)
			
	# create number box list. ez
	
	var group := ButtonGroup.new()
	for i in NUMLIST :
		var button := Button.new()
		button.text = str(i)
		button.size_flags_horizontal = 1 | 2
		button.toggle_mode = true
		button.group = group
		button.connect("pressed", self, "_on_pressed_numbutton", [button])
		button_list.append(button)
		hbox_count.add_child(button)
		
		if loaded_player_count == i :
			# press that button
			selected_bot_count = i
			selected_bot_count_button = button
			selected_bot_count_button.pressed = true
		
	if loaded_player_count == -1 :
		# select first
		selected_bot_count = NUMLIST[0]
		selected_bot_count_button = button_list[0]
		selected_bot_count_button.pressed = true
		
	if loaded_mode  == 0 or loaded_mode == -1 :
		normal_button.pressed = true
		selected_mode = 0
	else :
		hard_button.pressed = true
		selected_mode = 1
		
	if custom :
		selected_bot_count = loaded_player_count # select now, whatever
		
func _on_pressed_numbutton(node : Button) :
	#if node == selected_bot_count_button :
	#	# selected. NO
	#	selected_bot_count_button.pressed = true
	#	return
		
	# old .-.
#	# UNSELECT PREV BUTTON 55555555555555555555555 (if it has)
#	if selected_bot_count_button :
#		selected_bot_count_button.pressed = false
		
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
	GameMaster.lobbyinput_mode = selected_mode
	
	ani.play("go_play")
	
#####################################################

func go_play() :
	GameMaster.start_game()

#####################################################

func save_settings() :
	var file := ConfigFile.new()
	file.set_value("settings", "lang", settings_lang)
	file.save("settings.cfg")

# CHANGE LANG BUTTONNNNNNNNNNNNNN

func _on_lang_en_pressed() :
	settings_lang = "en"
	TranslationServer.set_locale(settings_lang)
	save_settings()

func _on_lang_th_pressed() :
	settings_lang = "th"
	TranslationServer.set_locale(settings_lang)
	save_settings()


func _on_normal_pressed() :
	selected_mode = 0

func _on_hard_pressed() :
	selected_mode = 1
