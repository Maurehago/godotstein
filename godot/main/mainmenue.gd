extends Control

# var Burg = preload("res://main/main.tscn").instance()

func _on_Button_button_up():
	Level.show_last()
	Gui.show_gui([])
	Level.player.start_move()
	# get_tree().get_root().add_child(Burg)
	# entweder nur ausblenden
	# self.visible = false
	# oder 
	# get_tree().get_root().remove_child(self)
