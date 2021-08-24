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

func _ready():
	# player
	player = $Player/KinematicBody
	player.stop_move()
	Level.player = player
	# 1. Levels anzeigen
	Level.show_level(["t1","t8","hof","egtuer"])
	# level.hide_all()
	Gui.show_gui(["menue"])
