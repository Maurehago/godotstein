extends Control

var Burg = preload("res://Main/Main.tscn").instance()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Button_button_up():
	get_tree().get_root().add_child(Burg)
	# entweder nur ausblenden
	# self.visible = false
	# oder 
	get_tree().get_root().remove_child(self)
	pass # Replace with function body.
