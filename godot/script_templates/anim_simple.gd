extends Spatial

export var animation_name: = "Hebel_down"
export var animation_player :NodePath

# Variablen
var isEnabled := false

# Objekte
var Animplayer:AnimationPlayer

# ====================
#   Funktionen
# --------------

# Hebel Runter
func anim_enable():
	Animplayer.play(animation_name)

# Hebel Hoch
func anim_disable():
	Animplayer.play_backwards(animation_name)


# ====================
#   intern
# --------------

# Called when the node enters the scene tree for the first time.
func _ready():
	# Animations_Player lesen
	Animplayer = get_node(animation_player)
	
	# Signal zuweisen
	Animplayer.connect("animation_finished", self, "_on_animation_finished")

func _on_animation_finished(anim_name):
	if anim_name == animation_name:
		isEnabled = !isEnabled
