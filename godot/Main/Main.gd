extends Spatial


# Objekte
var player:KinematicBody

# wenn Tastendruck
func _unhandled_key_input(_event):
	
	# bei Excape Menue
	if Input.is_key_pressed(KEY_ESCAPE):
		#get_tree().quit()
		Level.player.stop_move()
		Gui.show_gui(["menue"])


# Called when the node enters the scene tree for the first time.
func _ready():
	# player
	#player = $Player/KinematicBody
	#player.stop_move()
	
	# 1. Levels anzeigen
	Level.show_level(["hof","egtuer","t1"])
	# Level.hide_all()
	Gui.show_gui(["menue"])
