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
	"hof": preload("res://Burg/Hof/Hof.tscn").instance(),
	"t1": preload("res://Burg/Turm/T1/T1.tscn").instance(),
	"t2": preload("res://Burg/Turm/T2/T2.tscn").instance(),
	"t3": preload("res://Burg/Turm/T3/T3.tscn").instance(),
	"t4": preload("res://Burg/Turm/T4/T4.tscn").instance(),
	"t5": preload("res://Burg/Turm/T5/T5.tscn").instance(),
	"t6": preload("res://Burg/Turm/T6/T6.tscn").instance(),
	"t7": preload("res://Burg/Turm/T7/T7.tscn").instance(),
	"t8": preload("res://Burg/Turm/T8/T8.tscn").instance(),
	"k01": preload("res://Burg/Keller/K01/K01.tscn").instance(),
	"k02": preload("res://Burg/Keller/K02/K02.tscn").instance(),
	"k03": preload("res://Burg/Keller/K03/K03.tscn").instance(),
	"k04": preload("res://Burg/Keller/K04/K04.tscn").instance(),
	"k05": preload("res://Burg/Keller/K05/K05.tscn").instance(),
	"k06": preload("res://Burg/Keller/K06/K06.tscn").instance(),
	"k07": preload("res://Burg/Keller/K07/K07.tscn").instance(),
	"k08": preload("res://Burg/Keller/K08/K08.tscn").instance(),
	"k09": preload("res://Burg/Keller/K09/K09.tscn").instance(),
	"k10": preload("res://Burg/Keller/K10/K10.tscn").instance(),
	"k11": preload("res://Burg/Keller/K11/K11.tscn").instance(),
	"k12": preload("res://Burg/Keller/K12/K12.tscn").instance(),
	"ktuerost": preload("res://Burg/Keller/KTuer/KTuerOst.tscn").instance(),
	"ktuerwest": preload("res://Burg/Keller/KTuer/KTuerWest.tscn").instance(),
	"eg01": preload("res://Burg/EG/EG01/EG01.tscn").instance(),
	"eg02": preload("res://Burg/EG/EG02/EG02.tscn").instance(),
	"eg03": preload("res://Burg/EG/EG03/EG03.tscn").instance(),
	"eg04": preload("res://Burg/EG/EG04/EG04.tscn").instance(),
	"eg05": preload("res://Burg/EG/EG05/EG05.tscn").instance(),
	"eg06": preload("res://Burg/EG/EG06/EG06.tscn").instance(),
	"eg07": preload("res://Burg/EG/EG07/EG07.tscn").instance(),
	"eg08": preload("res://Burg/EG/EG08/EG08.tscn").instance(),
	"eg09": preload("res://Burg/EG/EG09/EG09.tscn").instance(),
	"eg10": preload("res://Burg/EG/EG10/EG10.tscn").instance(),
	"eg11": preload("res://Burg/EG/EG11/EG11.tscn").instance(),
	"eg12": preload("res://Burg/EG/EG12/EG12.tscn").instance(),
	"egtuer": preload("res://Burg/EG/EGTuer/EgTuer.tscn").instance(),
}

# objekte
var player:KinematicBody

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

func hide_all():
	# alle in der alten Liste durchgehen
	for levelName in levelList:
		# wenn nicht in der neuen Liste -> dann entfernen
		if Levels.has(levelName):
			call_deferred("_remove_scene", Levels[levelName])
	

func show_last():
	show_level(levelList)
	

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
	# GUI mit aufnehmen
	pass
	
