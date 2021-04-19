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
export var mouse_sensivity: = 20
export var camera_shake_frequenz: = 7
export var camera_shake_power: = 0.1


export var gravity : = 9.81
export var max_speed: = 3.0
export var max_running_speed: = 6.0
export var accel: = 4
export var deaccel: = 6

export var max_jump_height: = 1
export var jump_speed: = 20

export(float, 0.1, 0.5) var max_stair_height: = 0.3
export var max_stair_angle: = 20
export var max_floor_angle: = 45

export var isFlying: = false
export var allowChangeFlying: = false
export var fly_speed: = 10.0
export var fly_accel: = 4.0

# =================
#  Tastatur Keys
# --------------
var keyForward: = KEY_W
var keyBack: = KEY_S
var keyLeft: = KEY_A
var keyRight: = KEY_D
var keyRun: = KEY_SHIFT
var keyJump: = KEY_SPACE
var keyDuck: = KEY_CONTROL
var keyFly: = KEY_G
var keyInteract: = KEY_F

# Movement
var input_forward := "move_forward"
var input_back := "move_back"
var input_left := "move_left"
var input_right := "move_right"
var input_run := "run"
var input_jump := "jump"
var input_duck := "duck"
var input_fly := "fly"
var input_interact := "interact"


# =================
#  Variablen
# --------------

# Sprunghöhe oder Stufenhöhe
var jump_pos := 0.0
var up_height:= 0.0

# Kamera Ausrichtung (für Einschränkung der Neigung, damt nicht im Kreis nach oben und unten gedreht werden kann)
var camera_angle: = 0.0

# Gravitation Zeit für drehung in Gravitationsrichtung
var gravity_time = 0.0

# Relative Maus Bewegung
var mouse_relative := Vector2()

# Transform bei Gravitations änderungen
var bodyBasis: Basis
var new_transform : Transform
var old_transform : Transform

# Wenn Bewegung aktiviert
var isMove := false
var isGravityChanged := false

var isCrouch := false
var isDown := false
var isForeward := false
var isBackward := false
var isLeft := false
var isRight := false
var isJump := false
var isSprint := false
var isOnFloor := false
var isInteract := false

# Node Elemente
var Player:KinematicBody = self
var currentTarget: Object
var Head: Spatial
var Nose: Spatial
var Cam: Camera
var Hand: RayCast
var ColStand: CollisionShape
var ColCrouch: CollisionShape

var LeftRay: RayCast
var RightRay: RayCast
var FrontRay: RayCast
var BackRay: RayCast

var FloorRay: RayCast
var TopRay: RayCast

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

	#var keyForward: = KEY_W
	_set_inputMap(input_forward, keyForward)

	#var keyBack: = KEY_S
	_set_inputMap(input_back, keyBack)

	#var keyLeft: = KEY_A
	_set_inputMap(input_left, keyLeft)

	#var keyRight: = KEY_D
	_set_inputMap(input_right, keyRight)

	#var keyRun: = KEY_SHIFT
	_set_inputMap(input_run, keyRun)

	#var keyJump: = KEY_SPACE
	_set_inputMap(input_jump, keyJump)

	#var keyDuck: = KEY_CONTROL
	_set_inputMap(input_duck, keyDuck)

	#var keyFly: = KEY_G
	_set_inputMap(input_fly, keyFly)

	#var keyInteract: = KEY_F
	_set_inputMap(input_interact, keyInteract)


#Bewegung aktivieren
func start_move():
	# Maus verstecken
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# Bewegung aktivieren
	isMove = true

#Bewegung deaktivieren
func stop_move():
	# Maus verstecken
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Bewegung deaktivieren
	isMove = false


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
			Nose.rotate(Nose.transform.basis.x, deg2rad(mouse_velocity.y))

		# Maus Bewegung zurücksetzen
		mouse_relative = Vector2()

# Fliegen
func fly(delta):
	# Zielrichtung * Flug Geschwindigkeit
	var target:Vector3 = direction * fly_speed
	bodyBasis = self.transform.basis
	
	if isJump:
		# nach oben
		target += bodyBasis.y

	if isDown:
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
	if isCrouch:
		return
		
	var isStep = false
	var ray: RayCast = null
	
	# wenn Bewegung
	# Stufe prüfen Vorwärts
	if isForeward and FrontRay.is_colliding():
		ray = FrontRay
		isStep = true
	
	# Stufe prüfen Rückwärts
	if isBackward and BackRay.is_colliding():
		ray = BackRay
		isStep = true

	# Stufe prüfen Links
	if isLeft and LeftRay.is_colliding():
		ray = LeftRay
		isStep = true

	# Stufe prüfen Rechts
	if isRight and RightRay.is_colliding():
		ray = RightRay
		isStep = true
	
	# Wenn Stufe gefunden
	if isStep:
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
				isJump = true
				

# Gehen
func walk(delta):
	# auf Stufen prüfen
	checkStair(delta)

	#Geschwindigkeit prüfen
	var speed
	
	# Wenn Laufen eingeschaltet
	if isSprint:
		# maximale Laufgeschwindigkeit
		speed = max_running_speed
	else:
		#maximale geh-Geschwindigkeit
		speed = max_speed
		
	# Gehen Ziel bestimmen
	var move_target:Vector3 = Vector3(direction) * speed
	
	# GRAVITATION hinzufügen
	if isJump:
		move_target += bodyBasis.y.normalized() * up_height * jump_speed
	elif !FloorRay.is_colliding():
		move_target -= bodyBasis.y * gravity
		
	#Beschleunigung bestimmen
	var acceleration

	# Wenn aktuelle Bewegung(velocity) und gewünschte Richtung(direction)
	# in die selbe Richtung (dot Produckt ist > 0)
	var dotProduckt = direction.dot(velocity)
	if dotProduckt > 0:
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
	if isJump and self.transform.origin.y - jump_pos > up_height:
		isJump = false
		velocity -= bodyBasis.y.normalized()
	
	
func wipe_cam(delta):
	# Kopfwippen
	if isForeward or isBackward or isLeft or isRight:
		# in_bewegung wird  auf true gesetzt([W][A][S][D])
		var frequenz = camera_shake_frequenz
		var power = camera_shake_power
		if isSprint:
			frequenz = frequenz* 2
			power = power /2
		
		cam_velocity += frequenz * delta
		if cam_velocity > PI:
			# nach >180° wird in_bewegung auf false und kann erneut gestartet werden
			cam_velocity = 0
		cam_velocity = fmod(cam_velocity, PI) # winkel auf Pi begrenzen
		var y = sin(cam_velocity) * power
		Cam.translation.y = y
	
# ======================
#   Gravitation
# ---------------

# nach Ziel ausrichten
func translate_to_target(target: Transform):
	# Transforms auf Player richten
	old_transform = Transform(self.global_transform.basis, self.transform.origin)
	new_transform = target

	# Gravitation auf geändert setzen
	isGravityChanged = true
	gravity_time = 0.0
	isMove = false


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
	if Hand.is_colliding():
		var Target = Hand.get_collider()
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
	if isMove:
		# Bewegungs Richtung zurücksetzen
		direction = Vector3.ZERO
		
		# Nase Ausrichtung lesen
		var noseBasis: Basis = Nose.get_global_transform().orthonormalized().basis
		bodyBasis = self.get_transform().orthonormalized().basis

		# Wenn Flugmodus umschaltbar
		if allowChangeFlying and Input.is_action_just_pressed(input_fly):
			#wenn im Flugmodus
			if isFlying:
				isFlying = false
			else:
				isFlying = true
		
		# wenn Interaktion
		if Input.is_action_pressed(input_interact):
			isInteract = true
			stop_move()
		
		# wenn ducken kriechen
		if Input.is_action_pressed(input_duck):
			if isFlying:
				isDown = true
			elif !isCrouch and FloorRay.is_colliding():
				isCrouch = true
				isDown = false
									
				# Ducken Collision
				ColCrouch.disabled = false
				ColStand.disabled = true
				
				FloorRay.enabled = false
		elif isCrouch and !TopRay.is_colliding():
			#scale_object_local(Vector3(1, 2, 1))
			transform.origin.y += 1
			ColStand.disabled = false
			ColCrouch.disabled = true
			FloorRay.enabled = true
			isCrouch = false
		else:
			#isCrouch = false
			isDown = false
		
		# Wenn nach vorne 'move_forward'
		if Input.is_action_pressed(input_forward):
			if isFlying:
				direction -= noseBasis.z
			else:
				direction -= bodyBasis.z # baseNormal.z
			isForeward = true
		else:
			isForeward = false
			
		# Wenn nach hinten 'move_backward'
		if Input.is_action_pressed(input_back):
			if isFlying:
				direction += noseBasis.z # baseNormal.z
			else:
				direction += bodyBasis.z # baseNormal.z
			isBackward = true
		else:
			isBackward = false
			
		# Wenn nach links 'move_left'
		if Input.is_action_pressed(input_left):
			direction -= bodyBasis.x # baseNormal.x
			isLeft = true
		else:
			isLeft = false
			
		# Wenn nach rechts 'move_right'
		if Input.is_action_pressed(input_right):
			direction += bodyBasis.x # baseNormal.x
			isRight = true
		else:
			isRight = false

		if Input.is_action_pressed(input_run):
			isSprint = true
		else:
			isSprint = false

		# Jump
		if isFlying and Input.is_action_pressed(input_jump):
			isJump = true
		elif FloorRay.is_colliding() and Input.is_action_just_pressed(input_jump):
			isJump = true
			jump_pos = self.transform.origin.y
			up_height = max_jump_height * jump_speed * 0.5
			direction += bodyBasis.y
		else:
			isJump = false
			# up_height = 0.0

		# Richtung Normalisieren
		direction = direction.normalized()

	else:
		if isInteract and !Input.is_action_pressed(input_interact):
			isInteract = false
			start_move()

# Eingaben prüfen
func _input(event):
	# Wenn Bewegung eingeschaltet
	if isMove:
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
	if isMove:
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
	
	if isGravityChanged:
		# GrafitationsZeit ändern
		gravity_time += delta
		self.global_transform = old_transform.interpolate_with(new_transform, gravity_time)

		# wenn Ende erreicht
		if self.global_transform == new_transform:
			isMove = true
			isGravityChanged = false

# Wenn die Szene geladen ist
func _ready():
	# Dummy Körper ausblenden
	# $Visible.visible = false
	
	# Objekt erstellen
	_build()
	
	# Tastatur zuordnen
	set_input_keys()
	
	# Nodes merken 
	Head = $Head
	Nose = $Head/Nose
	Cam = $Head/Nose/Cam
	Hand = $Head/Nose/Hand
	ColStand = $Stand
	ColCrouch = $Crouch
	ColCrouch.disabled = true
	
	LeftRay = $Feet/LeftRay
	RightRay = $Feet/RightRay
	FrontRay = $Feet/FrontRay
	BackRay = $Feet/BackRay
	TopRay = $Crouch/TopRay
	FloorRay = $Feet/FloorRay
	
	# Wenn Level dan Player übergeben
	if Level:
		Level.player = self
	
	# Bewegung starten
	# todo: in Main auslagern ?
	# start_move()
