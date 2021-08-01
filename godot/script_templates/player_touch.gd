extends Area

# ====================
#   Skript Template
#-------------------
# Wenn der Player die Area berührt
# können beim Ziel/ Target aktionen gesetzt werden

# Einstellungen
export var target: NodePath

# Variablen
var isInteract = false

# Objekte
var animTarget:Spatial

# Wenn Player in der nähe
func touch_player(_player):
	isInteract = true

# Wenn kein Player in der nähe
func touch_player_end(_player):
	isInteract = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ziel Objekt zuweisen
	animTarget = get_node(target)

	# Einstellungen
	self.collision_layer = 1024 # 11
	self.collision_mask = 1024	# 11
	self.input_capture_on_drag = true	# Damit die Maus erkannt wird 
	
	# Signal verbinden
	self.connect("input_event", self, "_on_input_event")


# Wenn mit der Maus rein geklickt wird
func _on_input_event(_camera, event, _click_position, _click_normal, _shape_idx):
	if isInteract:
		if event is InputEventMouseButton:
			if animTarget.isEnabled:
				if animTarget.has_method("anim_disable"):
					animTarget.anim_disable()
			else:
				if animTarget.has_method("anim_enable"):
					animTarget.anim_enable()
