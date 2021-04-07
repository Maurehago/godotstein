extends Spatial

# =======================
#  Skript Template
# -----------------
# für Level/Szenen Wechseln
# Alle benötigten Szenen im Levels Dictionary vorladen
#
# Die Levels werden dan per "level_test"-Skript an diese Node eingefügt oder entfernt


# Levels - Liste alle vorgeladenen Level/Szenen mit eindeutiger ID (01,02, ..) 
var Levels:Dictionary = {
	"test": preload("res://Burg/Test/Test_Level.tscn").instance(),
}

# Variablen
var levelList:Array

# ==========================
#   Funktionen
# -------------

func show_level(newList:Array):
	# alle in der neuen Liste durchgehen
	for newName in newList:
		if !levelList.has(newName):
			if Levels.has(newName):
				call_deferred("_add_scene", Levels[newName])
				
	# alle in der alten Liste durchgehen
	for levelName in levelList:
		# wenn nicht in der neuen Liste -> dann entfernen
		if !newList.has(levelName):
			if Levels.has(levelName):
				call_deferred("_remove_scene", Levels[levelName])

	# neue Liste merken
	levelList = newList

# ==========================
#   Intern
# -----------

# Szene hinzufügen
func _add_scene(scene:Node):
	if !scene:
		return
	add_child(scene)

# Szene entfernen
func _remove_scene(scene:Node):
	if !scene:
		return
	remove_child(scene)
	scene.set_owner(null)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
