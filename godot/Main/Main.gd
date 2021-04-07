extends Spatial


# wenn Tastendruck
func _unhandled_key_input(_event):
	
	# bei Excape beenden
	if Input.is_key_pressed(KEY_ESCAPE):
		get_tree().quit()


# Called when the node enters the scene tree for the first time.
func _ready():
	# 1. Levels anzeigen
	Level.show_level(["test"])
