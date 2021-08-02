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
	"hof": preload("res://burg/hof/hof.tscn").instance(),
	"bibliothek": preload("res://burg/eg/bibliothek/bibliothek.tscn").instance(),
	"t1": preload("res://burg/turm/t1/t1.tscn").instance(),
	"t2": preload("res://burg/turm/t2/t2.tscn").instance(),
	"t3": preload("res://burg/turm/t3/t3.tscn").instance(),
	"t4": preload("res://burg/turm/t4/t4.tscn").instance(),
	"t5": preload("res://burg/turm/t5/t5.tscn").instance(),
	"t6": preload("res://burg/turm/t6/t6.tscn").instance(),
	"t7": preload("res://burg/turm/t7/t7.tscn").instance(),
	"t8": preload("res://burg/turm/t8/t8.tscn").instance(),
	"k01": preload("res://burg/keller/k01/k01.tscn").instance(),
	"k02": preload("res://burg/keller/k02/k02.tscn").instance(),
	"k03": preload("res://burg/keller/k03/k03.tscn").instance(),
	"k04": preload("res://burg/keller/k04/k04.tscn").instance(),
	"k05": preload("res://burg/keller/k05/k05.tscn").instance(),
	"k06": preload("res://burg/keller/k06/k06.tscn").instance(),
	"k07": preload("res://burg/keller/k07/k07.tscn").instance(),
	"k08": preload("res://burg/keller/k08/k08.tscn").instance(),
	"k09": preload("res://burg/keller/k09/k09.tscn").instance(),
	"k10": preload("res://burg/keller/k10/k10.tscn").instance(),
	"k11": preload("res://burg/keller/k11/k11.tscn").instance(),
	"k12": preload("res://burg/keller/k12/k12.tscn").instance(),
	"k13": preload("res://burg/keller/k13/k13.tscn").instance(),
	"ktuerost": preload("res://burg/keller/ktuer/ktuerost.tscn").instance(),
	"ktuerwest": preload("res://burg/keller/ktuer/ktuerwest.tscn").instance(),
	"eg01": preload("res://burg/eg/eg01/eg01.tscn").instance(),
	"eg02": preload("res://burg/eg/eg02/eg02.tscn").instance(),
	"eg03": preload("res://burg/eg/eg03/eg03.tscn").instance(),
	"eg04": preload("res://burg/eg/eg04/eg04.tscn").instance(),
	"eg05": preload("res://burg/eg/eg05/eg05.tscn").instance(),
	"eg06": preload("res://burg/eg/eg06/eg06.tscn").instance(),
	"eg07": preload("res://burg/eg/eg07/eg07.tscn").instance(),
	"eg08": preload("res://burg/eg/eg08/eg08.tscn").instance(),
	"eg09": preload("res://burg/eg/eg09/eg09.tscn").instance(),
	"eg10": preload("res://burg/eg/eg10/eg10.tscn").instance(),
	"eg11": preload("res://burg/eg/eg11/eg11.tscn").instance(),
	"eg12": preload("res://burg/eg/eg12/eg12.tscn").instance(),
	"egtuer": preload("res://burg/eg/egtuer/egtuer.tscn").instance(),
	"ogtuer": preload("res://burg/og/ogtuer/ogtuer.tscn").instance(),
	"og02": preload("res://burg/og/og02/og02.tscn").instance(),
	"og03": preload("res://burg/og/og03/og03.tscn").instance(),
	"og04": preload("res://burg/og/og04/og04.tscn").instance(),
	"og05": preload("res://burg/og/og05/og05.tscn").instance(),
	"og06": preload("res://burg/og/og06/og06.tscn").instance(),
	"og08": preload("res://burg/og/og08/og08.tscn").instance(),
	"og09": preload("res://burg/og/og09/og09.tscn").instance(),
	"og10": preload("res://burg/og/og10/og10.tscn").instance(),
	"og11": preload("res://burg/og/og11/og11.tscn").instance(),
	"og12": preload("res://burg/og/og12/og12.tscn").instance(),
}

# objekte
var player:KinematicBody

# Variablen
var levelList:Array

# ==========================
#   Funktionen
# -------------

# Zeigt die registrierten Szenen vom angegebenen Array an
# ["hof", "t2"] - aktuell
# ["t1", "t2", "t3", "dummy"] - neu
func show_level(newList:Array):
	# alle in der neuen Liste durchgehen
	for newName in newList:
		if !levelList.has(newName): # ob noch nicht angezeigt
			if Levels.has(newName): # ob Level in der Liste
				call_deferred("_add_scene", Levels[newName])
				
	# alle in der alten Liste durchgehen
	for levelName in levelList:
		# wenn nicht in der neuen Liste -> dann entfernen
		if !newList.has(levelName):
			if Levels.has(levelName):
				call_deferred("_remove_scene", Levels[levelName])

	# neue Liste merken
	levelList = newList

# entfernt alle aktuellen Szenen
func hide_all():
	# alle in der alten Liste durchgehen
	for levelName in levelList:
		# wenn nicht in der neuen Liste -> dann entfernen
		if Levels.has(levelName):
			call_deferred("_remove_scene", Levels[levelName])
	

# zeigt die zuletzt verwendeten szenen wieder an
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
	
