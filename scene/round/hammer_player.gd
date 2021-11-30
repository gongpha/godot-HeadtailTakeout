extends KinematicBody2D
class_name RoundHammerPlayer

# ni nae (ouch)
# tai X_X

# just a simple platformer character ^^

onready var body_node : Sprite = $body
onready var face_node : Sprite = $face
onready var hammer_node : Sprite = $hammer
onready var ani : AnimationPlayer = $ani
onready var name_node : Label = $name
onready var cam : Camera2D = $cam
onready var push : Area2D = $push
onready var attack : Area2D = $attack
onready var sound : AudioStreamPlayer2D = $sound
onready var jump_s : AudioStreamPlayer2D = $jump
onready var attack_col : CollisionShape2D = $attack/col
onready var dmgface : Timer = $dmgface

var damaged : Texture = preload("res://resource/texture/charac/char_damaged.atlastex")

var vel : Vector2

var at_map : RoundHammerMap

var player : Player
var player_id : int

var attack_wait : bool = false

var cpu : bool = true # bot ?

var cpu_target : KinematicBody2D # same class. but the cyclic ref bruh
var last_target_pos : Vector2
var path : PoolVector2Array

signal hit(victim, vid)

func _ready() :
	set_physics_process(false)
	
	if player :
		name_node.set_message_translation(false)
		name_node.text = player.name
		body_node.texture = player.icon_bg
		face_node.texture = player.icon_fg
		
func fetch_target(example : KinematicBody2D = null) :
	var round_ := GameMaster.current_round as RoundStage # !!! cyclic
	if not cpu_target :
		if GameMaster.is_player_rival() and round_.my_player :
			# target human XD
			cpu_target = round_.my_player
		else :
			if randi() % 4 == 0 and example :
				cpu_target = example
			else :
				# find new target
				while true :
					cpu_target = round_.players_list[randi() % round_.players_list.size()]
					if cpu_target != self :
						break
	_update_path()
		
func _update_path() :
	var my_pos := global_transform.origin
	last_target_pos = cpu_target.global_transform.origin
	path = at_map.nav.get_simple_path(my_pos, last_target_pos)
	
func _draw() :
	return
	var paths := []
	for p in path :
		paths.append(p - global_transform.origin)
	draw_multiline(paths, Color.red)
	
	draw_circle(last_target_pos - global_transform.origin, 2, Color.green)

func _physics_process(delta : float) :
	var right_axis : int
	var jump : bool
	if not cpu :
		jump = Input.is_action_just_pressed("jump")
		right_axis = int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
		attack_wait = Input.is_action_just_pressed("attack")
	
	
	else :
		if cpu_target :
			var direction : Vector2
			var step : float = delta * 512
			var my_pos := global_transform.origin
			var leng := last_target_pos.distance_to(cpu_target.global_transform.origin)
			if leng > 64 : # UPDATE PATH WHEN TARGET MOVE (more than 16px)
				_update_path()
				
			# move to that point
			if path.size() > 0 :
				var dest := path[0]
				direction = dest - my_pos
				
				if direction.length() < 16 :
					step = direction.length()
					path.remove(0) # BRUH. OPTIMIZE PLZ
				else :
					if direction.x < -16 :
						right_axis = -1
					elif direction.x > 16 :
						right_axis = 1
					else :
						right_axis = 0
						
					if direction.y < -32 :
						jump = true
			else :
				# not move. face to target
				if direction.x < 0 :
					right_axis = -1
				elif direction.x > 0 :
					right_axis = 1
	#var down_axis := int(Input.is_action_pressed("move_down")) - int(Input.is_action_pressed("move_up"))
	
	if right_axis < 0 :
		face_node.position.x = -4
		hammer_node.position.x = -32
		attack_col.position.x = -81
	elif right_axis > 0 :
		face_node.position.x = 4
		hammer_node.position.x = 32
		attack_col.position.x = 81
	
	if not is_on_floor() :#not on_floor_ray.is_colliding() :
		vel.y += 32
	else :
		vel.y = 0
		if jump :
			vel.y -= 1024
			jump_s.play()
	
	vel.x = lerp(vel.x, right_axis * 512, delta * 15)
	#print(on_floor_ray.is_colliding())
	
	vel = move_and_slide(vel, Vector2.UP)
	
	# push
	for b in push.get_overlapping_bodies() :
		if b == self :
			# skip if it's my self
			continue
		#if b.has_method() :
		b.vel += b.global_transform.origin.direction_to(global_transform.origin) * -32
	
	# action
	if attack_wait :
		if not ani.is_playing() :
			if face_node.position.x == -4 :
				ani.play("hammer_hit_left")
			else :
				ani.play("hammer_hit_right")
		attack_wait = false


func _on_attack_body_entered(body) :
	if cpu :
		if GameMaster.is_player_rival() :
			if body == GameMaster.current_round.my_player :
				attack_wait = true
		else :
			if body is KinematicBody2D :
				attack_wait = true
				
func received_damage() :
	face_node.texture = damaged
	dmgface.start()
	
func commit_attack() :
	var bs := attack.get_overlapping_bodies()
	for b in bs :
		emit_signal("hit", b.player, b.player_id)
		
		b.received_damage()
		if b.cpu :
			b.cpu_target = null
			b.fetch_target(self) # change target
	
	if not bs.empty() :
		sound.play()
		
func _on_ani_animation_finished(anim_name) :
	var bs : Array = attack.get_overlapping_bodies()
	if GameMaster.is_player_rival() :
		if bs.has(GameMaster.current_round.my_player) :
			attack_wait = true
	else :
		if not bs.empty() :
			attack_wait = true


func _on_dmgface_timeout() :
	face_node.texture = player.icon_fg
