extends Area		# für 3D
#extends Area2D		# für 2D

# ==================
#  Skript-Template
# ----------------
# benötigt das Singelton "Level" Skript
# mit der Funktion "show_level()" 


# Level Liste die angezeigt werden soll
# alle anderen werden aus der Anzeige entfernt
export var level_list:String

func _ready():
	# Collisions Layer setzen
	self.collision_layer = 512
	self.collision_mask = 512

	# Signal verbinden
	var _err = self.connect("body_entered", self, "_on_body_entered")

# Wenn jemand in die Area kommt
func _on_body_entered(_body):
	# Wenn Level Skript vorhanden
	if Level and Level.has_method("show_level"):
		var list = level_list.split(",")
		Level.show_level(list)
