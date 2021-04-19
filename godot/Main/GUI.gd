extends CanvasLayer


# GUI Szenen
var Guis:Dictionary = {
	"menue": preload("res://Main/MainMenue.tscn").instance(),
}

# Variablen
var guiList:Array

func show_gui(newList:Array):
	# alle in der neuen Liste durchgehen
	for newName in newList:
		if !guiList.has(newName):
			if Guis.has(newName):
				call_deferred("_add_gui", Guis[newName])
				
	# alle in der alten Liste durchgehen
	for guiName in guiList:
		# wenn nicht in der neuen Liste -> dann entfernen
		if !newList.has(guiName):
			if Guis.has(guiName):
				call_deferred("_remove_gui", Guis[guiName])

	# neue Liste merken
	guiList = newList

# GUI hinzufügen
func _add_gui(scene:Node):
	if !scene:
		return
	add_child(scene)

# Szene entfernen
func _remove_gui(scene:Node):
	if !scene:
		return
	remove_child(scene)
	scene.set_owner(null)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

