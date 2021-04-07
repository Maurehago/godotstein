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
	"01": preload("res://Level/Level_01.tscn").instance(),
	"02": preload("res://Level/Level_02.tscn").instance(),
	"03": preload("res://Level/Level_03.tscn").instance(),
	"04": preload("res://Level/Level_04.tscn").instance(),
	"05": preload("res://Level/Level_05.tscn").instance(),
	"06": preload("res://Level/Level_06.tscn").instance(),
	"07": preload("res://Level/Level_07.tscn").instance(),
	"08": preload("res://Level/Level_08.tscn").instance(),
	"09": preload("res://Level/Level_09.tscn").instance(),
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
	
