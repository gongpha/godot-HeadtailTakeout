extends Reference
class_name Player

# abstract player for gaming
# no instance in world at all 555+

enum Type {
	PLAYER, BOT
}

var name := "@@@" # placeholder
var icon_bg : Texture # the base icon (circle)
var icon_fg : Texture # face
var icon_hue : float # more variation
var type : int = Type.BOT # start as bot
var eliminated := false # fail yet
var eliminated_being_head := true # fail because being head ?

# for round
var data # any. most are integer or float for sorting
