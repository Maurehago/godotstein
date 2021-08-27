extends KinematicBody

# =================
#  Node Struktur
# ---------------

#- Player (KinematicBody)
#	- Feet (Spatial)
#		- FloorRay (RayCast)
#		- FrontRay (RayCast)
#		- BackRay (RayCast)
#		- LeftRay (RayCast)
#		- RightRay (RayCast)
#	- Stand (CollisionShape)
#	- Crouch (CollisionShape)
#		- TopRay (RayCast)
#	- Head (Spatial)
#		- Noise (Spatial)
#			- Camera
#			- Hand (RayCast)

# ===============================
# Export Variablen
# ------------------
export var mouse_sensivity: float = 20
export var camera_shake_frequenz: float = 7
export var camera_shake_power: float = 0.1

export var gravity: float = 9.81
export var max_speed: float = 3.0
export var max_running_speed: float = 6.0
export var accel: float = 4
export var deaccel: float = 6

export var max_jump_height: float = 1
export var jump_speed: float = 20

export(float, 0.1, 0.5) var max_stair_height: = 0.3
export var max_stair_angle: float = 20
export var max_floor_angle: float = 45

export var isFlying: bool = false
export var allowChangeFlying: bool = false
export var fly_speed: float = 10.0
export var fly_accel: float = 4.0

# =================
#  Tastatur Keys
# --------------

enum key {
	FORWARD=KEY_W,
	BACK=KEY_S,
	LEFT=KEY_A,
	RIGHT=KEY_D,
	RUN=KEY_SHIFT,
	JUMP=KEY_SPACE,
	DUCK=KEY_CONTROL,
	FLY=KEY_G,
	INTERACT=KEY_F
}

# Movement
const input:Dictionary = {
	"forward": "move_forward",
	"back": "move_back",
	"left": "move_left",
	"right": "move_right",
	"run": "run",
	"jump": "jump",
	"duck": "duck",
	"fly": "fly",
	"interact": "interact"
}

# =================
#  Variablen
# --------------

# Sprunghöhe oder Stufenhöhe
var jump_pos: float = 0.0
var up_height: float = 0.0

# Kamera Ausrichtung (für Einschränkung der Neigung, damt nicht im Kreis nach oben und unten gedreht werden kann)
var camera_angle: float = 0.0

# Gravitation Zeit für drehung in Gravitationsrichtung
var gravity_time: float = 0.0

# Relative Maus Bewegung
var mouse_relative := Vector2()

# Transform bei Gravitations änderungen
var bodyBasis: Basis
var new_transform : Transform
var old_transform : Transform

# Wenn Bewegung aktiviert
var state:Dictionary = {
	"isForward": false,
	"isBackward": false,
	"isLeft": false,
	"isRight": false,
	"isMove": false,
	"isGravityChanged": false,
	"isCrouch": false,
	"isDown": false,
	"isJump": false,
	"isSprint": false,
	"isOnFloor": false,
	"isInteract": false
}

# Node Elemente
var Player:KinematicBody = self
var currentTarget: Object

onready var Nodes:Dictionary = {
	"Head": NodePath("Head"),
	"Nose": NodePath("Head/Nose"),
	"Cam": NodePath("Head/Nose/Cam"),
	"Hand": NodePath("Head/Nose/Hand"),
	"ColStand": NodePath("Stand"),
	"ColCrouch": NodePath("Crouch")
}

onready var Ray:Dictionary = {
	"Front": NodePath("Feet/FrontRay"),
	"Back": NodePath("Feet/BackRay"),
	"Left": NodePath("Feet/LeftRay"),
	"Right": NodePath("Feet/RightRay"),
	"Top": NodePath("Crouch/TopRay"),
	"Floor": NodePath("Feet/FloorRay")
}


# Bewegung Richtung
var direction: = Vector3()

# Bewegung
var velocity: = Vector3()
var mouse_velocity := Vector2()
var cam_velocity := 0.0

# =============================
#   Funktionen
# -------------

func _build_feet(name:String, pos:Vector3) -> RayCast:
	var ray := RayCast.new()
	ray.name = name
	ray.cast_to = Vector3(0, -0.5, 0)
	ray.transform.origin = pos
	ray.add_to_group("Feet")
	ray.enabled = true
	return ray

# Erstellt alle notwendigen Player nodes
func _build():
	# Füsse
	var Feet:Spatial = Spatial.new()
	Feet.name = "Feet"
	self.add_child(Feet)
	Feet.transform.origin.y = 0.51
	
	var FRay:RayCast = RayCast.new()
	FRay.name = "FloorRay"
	FRay.enabled = true
	FRay.cast_to = Vector3(0, -0.6, 0)
	FRay.add_to_group("Feet")
	Feet.add_child(FRay)

	Feet.add_child(_build_feet("FrontRay", Vector3(0 ,0, -0.3)))
	Feet.add_child(_build_feet("BackRay", Vector3(0, 0, 0.3)))
	Feet.add_child(_build_feet("LeftRay", Vector3(-0.3, 0, 0)))
	Feet.add_child(_build_feet("RightRay", Vector3(0.3, 0, 0)))

	# Kopf
	var H1 := Spatial.new()
	H1.name = "Head"
	H1.transform.origin.y = 1.6
	var N := Spatial.new()
	N.name = "Nose"
	var C := Camera.new()
	C.name = "Cam"
	var H2 := RayCast.new()
	H2.name = "Hand"
	
	H2.enabled = true
	H2.cast_to = Vector3(0, 0, -1.2)
	H2.collision_mask = 1024
	H2.transform.origin.z = 0.2
	H2.collide_with_areas = true
	
	N.add_child(C)
	N.add_child(H2)
	
	H1.add_child(N)
	self.add_child(H1)
	
	# Kollision
	var Stand := CollisionShape.new()
	Stand.name = "Stand"
	var Capsule := CapsuleShape.new()
	# Capsule.name = "Capsule"
	Capsule.radius = 0.2
	Capsule.height = 1.4
	Stand.shape = Capsule
	Stand.transform.basis.y = Vector3(0, 0, 1)
	Stand.transform.basis.z = Vector3(0, -1, 0)
	Stand.transform.origin.y = 0.9
	self.add_child(Stand)

	var Crouch := CollisionShape.new()
	Crouch.name = "Crouch"
	var Cap2 := CapsuleShape.new()
	# Cap2.name = "Cap2"
	var TRay := RayCast.new()
	TRay.name = "TopRay"
	
	Cap2.radius = 0.2
	Cap2.height = 0.5
	
	TRay.enabled = true
	TRay.cast_to = Vector3(0, 0.9, 0)
	TRay.transform.basis.y = Vector3(0, -0, -1)
	TRay.transform.basis.z = Vector3(0, 1, -0)
	TRay.transform.origin.y = -0.45
	
	Crouch.shape = Cap2
	Crouch.transform.basis.y = Vector3(0, 0, 1)
	Crouch.transform.basis.z = Vector3(0, -1, 0)
	Crouch.transform.origin.y = 1.35
	Crouch.add_child(TRay)
	self.add_child(Crouch)
	
	self.collision_layer = 513
	self.collision_mask = 513

func _set_inputMap(mapName:String, keyCode: int ):
	# prüfen ob Mapname vorhanden
	if !InputMap.has_action(mapName):
		InputMap.add_action(mapName)
		
	# key zuweisen
	var iek = InputEventKey.new()
	iek.scancode = keyCode
	InputMap.action_add_event(mapName, iek)
		
#Tasten zuordnen
func set_input_keys():
	# Tasten zuordnen
	for index in range(0,input.size()):
		_set_inputMap(input.values()[index], key.values()[index])

#Bewegung aktivieren
func start_move():
	# Maus verstecken
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	# Bewegung aktivieren
	state.isMove = true

#Bewegung deaktivieren
func stop_move():
	# Maus verstecken
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	# Bewegung deaktivieren
	state.isMove = false

# Rotation
func rotate_body(delta):
	# Wenn Bewegung eingeschaltet
	# nur wenn eine MausBewegung
	if mouse_relative.length() > 0 :
		# Mit Maus Sensibilität multiplizieren
		var mouse_dist:Vector2 = -mouse_relative # kommt von _input MouseMotion
		# Bewegung weich machen
		mouse_velocity = mouse_velocity.linear_interpolate(mouse_dist * mouse_sensivity, delta)
		# print("mouse_velocity: ", mouse_velocity)
		# um eigene Y-Achse drehen
		self.rotate(bodyBasis.y, deg2rad(mouse_velocity.x))
		# Prüfen ob die Mausbewegung + der Kamera ausrichtung innerhalb des erlaupten Sichtfeldes ist
		if mouse_velocity.y + camera_angle < 90 and mouse_velocity.y + camera_angle > -90:
			# Änderung zur Kamera Bewegung hinzufügen
			camera_angle += mouse_velocity.y
			# Nase (Vertical) um die X-Achse der Nase rotieren
			
			get_node(Nodes.Nose).rotate(get_node(Nodes.Nose).transform.basis.x, deg2rad(mouse_velocity.y))
		# Maus Bewegung zurücksetzen
		mouse_relative = Vector2()

# Fliegen
func fly(delta):
	# Zielrichtung * Flug Geschwindigkeit
	var target:Vector3 = direction * fly_speed
	bodyBasis = self.transform.basis
	if state.isJump:
		# nach oben
		target += bodyBasis.y
	if state.isDown:
		# nach unten
		target -= bodyBasis.y
	target = target.normalized()
	# Linear iterpolieren für Weichere Bewegung
	velocity = velocity.linear_interpolate(target * fly_speed, fly_accel * delta)
	# Spieler bewegen
	velocity = move_and_slide(velocity)

# Stufen
func checkStair(_delta):
	# Wenn gedückt	
	# dann kann man keine Stufen steigen
	if state.isCrouch:
		return
	var ray: RayCast = null
	# wenn Bewegung
	# Stufe prüfen Vorwärts
	for i in range(0,4):
		if state[i]:
			if get_node(Ray.values()[i]).is_colliding():
				ray = get_node(Ray.values()[i])
				isStep(ray)
		
# Wenn Stufe gefunden
func isStep(ray: RayCast):
	# Höhe der Stufe zu der eigenen Position ermitteln
	var stairHigh = (ray.get_collision_point() * bodyBasis.y).distance_to(self.global_transform.origin * bodyBasis.y)
	# nur wenn nicht die maximale Stufen-Höhe überschritten
	if stairHigh <= max_stair_height:
		# Stufe Fläche prüfen
		var stair_normal = ray.get_collision_normal()
		var stair_angle = rad2deg(acos(stair_normal.dot(bodyBasis.y)))
		# nur wenn eine flache Stufe
		if stair_angle < max_stair_angle:
			# Sprung auf Stufe einstellen
			up_height = stairHigh
			jump_pos = self.transform.origin.y
			state.isJump = true

# Gehen
func walk(delta):
	# auf Stufen prüfen
	checkStair(delta)
	#Geschwindigkeit prüfen
	var speed
	# Wenn Laufen eingeschaltet
	if state.isSprint:
		# maximale Laufgeschwindigkeit
		speed = max_running_speed
	else:
		#maximale geh-Geschwindigkeit
		speed = max_speed
	# Gehen Ziel bestimmen
	var move_target:Vector3 = Vector3(direction) * speed
	# GRAVITATION hinzufügen
	if state.isJump:
		move_target += bodyBasis.y.normalized() * up_height * jump_speed
	elif !get_node(Ray.Floor).is_colliding():
		move_target -= bodyBasis.y * gravity
	#Beschleunigung bestimmen
	var acceleration
	# Wenn aktuelle Bewegung(velocity) und gewünschte Richtung(direction)
	# in die selbe Richtung (dot Produkt ist > 0)
	var dotProdukt = direction.dot(velocity)
	if dotProdukt > 0:
		# Beschleunigen
		acceleration = accel
	else:
		#Abbremsen
		acceleration = deaccel
	# für sanfte Bewegung linear Interpolieren
	velocity = velocity.linear_interpolate(move_target, acceleration * delta)
	# Spieler Bewegen
	# 2 Parameter (Vector3(0,1,0) gibt an in welche Richtung der Boden schaut
	# für die Prüfung ob der Spieler am Boden Steht
	velocity = self.move_and_slide(velocity, bodyBasis.y, true, 4, deg2rad(max_floor_angle))
	bodyBasis = self.transform.basis
	# Sprunghöhe begrenzen
	if state.isJump and self.transform.origin.y - jump_pos > up_height:
		state.isJump = false
		velocity -= bodyBasis.y.normalized()
	
func wipe_cam(delta):
	# Kopfwippen
	if state[0] or state[1] or state[2] or state[3]:
		# in_bewegung wird  auf true gesetzt([W][A][S][D])
		var frequenz = camera_shake_frequenz
		var power = camera_shake_power
		if state.isSprint:
			frequenz = frequenz* 2
			power = power /2
		cam_velocity += frequenz * delta
		if cam_velocity > PI:
			# nach >180° wird in_bewegung auf false und kann erneut gestartet werden
			cam_velocity = 0
		cam_velocity = fmod(cam_velocity, PI) # winkel auf Pi begrenzen
		var y = sin(cam_velocity) * power
		get_node(Nodes.Cam).translation.y = y
	
# ======================
#   Gravitation
# ---------------

# nach Ziel ausrichten
func translate_to_target(target: Transform):
	# Transforms auf Player richten
	old_transform = Transform(self.global_transform.basis, self.transform.origin)
	new_transform = target
	# Gravitation auf geändert setzen
	state.isGravityChanged = true
	gravity_time = 0.0
	state.isMove = false
# neue Gravitation setzen
func set_new_gravity(newValue: float ):
	# Werte übernehmen
	gravity = newValue

# ======================
#  Interaktion
# ----------------------

# pruefen ob die Hand ein Objekt beruehrt
func _check_hand():
	# Wenn ein Gegenstand mit der Hand berührt wird
	if get_node(Nodes.Hand).is_colliding():
		var Target = get_node(Nodes.Hand).get_collider()
		# print("Target: ", Target)
		# wenn ein neuer Gegenstand
		if currentTarget != Target:
			# print("Target: ", Target)
			# Methode/ Funktion "touch_player()" beim Target aufrufen
			# es wird der Player als Parameter übergeben 
			if Target.has_method("touch_player"):
				Target.touch_player(self)
			
			# aktuelles Collisions-Objekt merken
			currentTarget = Target
	elif currentTarget:
		# Methode/ Funktion "touch_player_end()" beim Target aufrufen
		# es wird der Player als Parameter übergeben 
		if currentTarget.has_method("touch_player_end"):
			# print("lost Target: ", currentTarget)
			currentTarget.touch_player_end(self)
		currentTarget = null

# ======================
#  Standard Funktionen
# ----------------------

func _check_key_input():
	# ESC taste 'ui_cancel'
	# auslagern in Main
	if state.isMove:
		# Bewegungs Richtung zurücksetzen
		direction = Vector3.ZERO
		# Nase Ausrichtung lesen
		var noseBasis: Basis = get_node(Nodes.Nose).get_global_transform().orthonormalized().basis
		bodyBasis = self.get_global_transform().orthonormalized().basis
		# Wenn Flugmodus umschaltbar
		if allowChangeFlying and Input.is_action_just_pressed(input.fly):
			#wenn im Flugmodus
			if isFlying:
				isFlying = false
			else:
				isFlying = true
		# wenn Interaktion
		if Input.is_action_pressed(input.interact):
			state.isInteract = true
			stop_move()
		# wenn ducken kriechen
		if Input.is_action_pressed(input.duck):
			if isFlying:
				state.isDown = true
			elif !state.isCrouch and get_node(Ray.Floor).is_colliding():
				state.isCrouch = true
				state.isDown = false
				# Ducken Collision
				get_node(Nodes.ColCrouch).disabled = false
				get_node(Nodes.ColStand).disabled = true
				get_node(Ray.Floor).enabled = false
		elif state.isCrouch and !get_node(Ray.Top).is_colliding():
			#scale_object_local(Vector3(1, 2, 1))
			transform.origin.y += 1
			get_node(Nodes.ColCrouch).disabled = true
			get_node(Nodes.ColStand).disabled = false
			get_node(Ray.Floor).enabled = true
			state.isCrouch = false
		else:
			#isCrouch = false
			state.isDown = false
		
		for i in range(0,4):
			state[i] = Input.is_action_pressed(input.values()[i])
			if state[i]:
				match i:
					0: # Wenn nach vorne 'move_forward'
						if isFlying:
							direction -= noseBasis.z
						else:
							direction -= bodyBasis.z # baseNormal.z
					1: # Wenn nach links 'move_left'
						if isFlying:
							direction += noseBasis.z # baseNormal.z
						else:
							direction += bodyBasis.z # baseNormal.z
					2: # Wenn nach links 'move_left'
						direction -= bodyBasis.x # baseNormal.x
					3: # Wenn nach rechts 'move_right'
						direction += bodyBasis.x # baseNormal.x
		
		# Jump
		if isFlying and Input.is_action_pressed(input.jump):
			state.isJump = true
		elif get_node(Ray.Floor).is_colliding() and Input.is_action_just_pressed(input.jump):
			state.isJump = true
			jump_pos = self.transform.origin.y
			up_height = max_jump_height * jump_speed * 0.5
			direction += bodyBasis.y
		else:
			state.isJump = false
			# up_height = 0.0
		
		# Richtung Normalisieren
		direction = direction.normalized()
	
	else: # !state.isMove
		if state.isInteract and !Input.is_action_pressed(input.interact):
			state.isInteract = false
			start_move()

# Eingaben prüfen
func _input(event):
	# Wenn Bewegung eingeschaltet
	if state.isMove:
		# Wenn Maus Bewegung (Umschauen)
		if event is InputEventMouseMotion:
			mouse_velocity = Vector2.ZERO
			# relative Mausbewegung merken
			mouse_relative = event.relative
			# mouse_relative = mouse_relative.linear_interpolate(event.relative * mouse_sensivity, 1)

#Game Process
func _process(delta):
	# Tasten prüfen
	_check_key_input()

# physic Process
# func _physics_process(delta):
	# nur Wenn Bewegung erlaubt
	if state.isMove:
		# Drehen
		rotate_body(delta)
		# Wenn im Flugmodus
		if isFlying:
			# fliegen
			fly(delta)
		else:
			# gehen
			walk(delta)
			
			# Kamera Bewegung
			wipe_cam(delta)
		# Hand Beruehrung testen
		_check_hand()
	if state.isGravityChanged:
		# GrafitationsZeit ändern
		gravity_time += delta
		self.global_transform = old_transform.interpolate_with(new_transform, gravity_time)
		# wenn Ende erreicht
		if self.global_transform == new_transform:
			state.isMove = true
			state.isGravityChanged = false

# Wenn die Szene geladen ist
func _ready():
	# Dummy Körper ausblenden
	# $Visible.visible = false
	# Objekt erstellen
	_build()
	# Tastatur zuordnen
	set_input_keys()
	get_node(Nodes.ColCrouch).disabled = true
	# Bewegung starten
	# todo: in Main auslagern ?
	start_move()
	
