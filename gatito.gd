extends KinematicBody2D

var motion = Vector2(0, 0)
var start_position = Vector2(512, 550)
var collision = null
var screen_size
# Reduced speed value because move_and_collide handles delta automatically
var kitten_speed = 200 

# Límites del movimiento del personaje
var limit_left = 0
var limit_right = 0
var limit_up = 0
var limit_down = 0
var limit_plus = 100

# Temporizador
var time_left = 30

# Vida total del gato
var life = 3
var can_take_damage = true

onready var fish1 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish1")
onready var fish2 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish2")
onready var fish3 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish3")
onready var timer_label = get_node("/root/jardin/CanvasLayer/GUI/TimerLabel")
onready var victory_overlay = get_node("/root/jardin/CanvasLayer/GUI/VictoryOverlay")
onready var victory_label = get_node("/root/jardin/CanvasLayer/GUI/VictoryLabel")

var fish_empty = preload("res://Sprites/life_empty.png")

# Posición y de la cámara
var cameraPosition_y = 0
var last_spawn_y = null

# Sprite del gatito
onready var gatito = $sprite_gatito

# Obstáculos
var objectInstance

onready var lago = preload("lago.tscn")
onready var arbusto = preload("arbusto.tscn")
onready var roca = preload("roca.tscn")
onready var healing_fish = preload("res://HealingFish.tscn")


func _ready():
	# CHANGE 1: Force browser to clear stuck keys on startup
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	Input.action_release("ui_up")
	Input.action_release("ui_down")

	randomize()
	
	if life > 0:
		get_tree().paused = false

	screen_size = get_viewport_rect().size

	limit_down = screen_size.y - limit_plus
	limit_up = limit_plus
	limit_left = limit_plus
	limit_right = 1024 - limit_plus

	self.position = Vector2(512, 400)
	set_process(true)

	timer_label.text = str(time_left)


func _physics_process(delta):
	cameraPosition_y = get_parent().get_node("Camera2D").get_camera_position().y
	limit_down = start_position.y + cameraPosition_y

	# Generar obstáculos una vez cada 50 unidades de cámara
	if last_spawn_y == null or abs(cameraPosition_y - last_spawn_y) >= 50:
		random_obstaculos(cameraPosition_y - 100)
		last_spawn_y = cameraPosition_y

	# Controles y movimiento
	motion = Vector2(0, 0)

	# CHANGE 2: Simplified movement using base kitten_speed
	if Input.is_action_pressed("ui_right"):
		motion.x = kitten_speed
		gatito.flip_v = false
		gatito.flip_h = false
		gatito.play("Run_Side")

	elif Input.is_action_pressed("ui_left"):
		motion.x = -kitten_speed
		gatito.flip_v = false
		gatito.flip_h = true
		gatito.play("Run_Side")

	elif Input.is_action_pressed("ui_up"):
		motion.y = -kitten_speed
		gatito.flip_v = false
		gatito.flip_h = false
		gatito.play("Run")

	elif Input.is_action_pressed("ui_down"):
		motion.y = kitten_speed
		gatito.flip_v = true
		gatito.flip_h = false
		gatito.play("Run")

	else:
		gatito.play("Idle")
		motion = Vector2(0, 0)

	# Comprobación de los límites
	if self.position.y >= limit_down:
		self.position.y = limit_down

	if self.position.x <= limit_left:
		self.position.x = limit_left
	elif self.position.x >= limit_right:
		self.position.x = limit_right

	# Colisión con un obstáculo
	collision = move_and_collide(motion * delta)

	if collision and can_take_damage:
		can_take_damage = false
		life -= 1
		gatito.play("Idle")
		restart_position()
		flicker()

		if life == 2:
			fish1.texture = fish_empty
		elif life == 1:
			fish2.texture = fish_empty
		elif life == 0:
			fish3.texture = fish_empty

		if life == 0:
			get_tree().change_scene("res://GameOverScreen.tscn")
		else:
			get_tree().paused = true
			yield(get_tree().create_timer(0.5), "timeout")
			get_tree().paused = false
			can_take_damage = true

	# Countdown, independent of collisions
	if time_left > 0:
		time_left -= delta
		timer_label.text = str(max(0, int(ceil(time_left))))
	
		if time_left <= 0:
			time_left = 0
			timer_label.text = "0"
	
			victory_overlay.visible = true
			victory_label.visible = true
	
			get_tree().paused = true
			yield(get_tree().create_timer(2.0), "timeout")
			get_tree().paused = false
			get_tree().change_scene("res://StartScreen.tscn")


# Reiniciar al gatito en su posición inicial
func restart_position():
	self.position = Vector2(start_position.x, start_position.y + cameraPosition_y)
	gatito.play("Idle")


func random_obstaculos(y):
	var obstacles = get_parent().get_parent().get_node("obstaculos")
	var x = 0
	var valid_position = false
	var attempts = 0

	# Buscar una posición suficientemente alejada
	while not valid_position and attempts < 20:
		x = rand_range(120, 904)
		valid_position = true

		for obstacle in obstacles.get_children():
			if abs(obstacle.position.y - y) < 100 and abs(obstacle.position.x - x) < 150:
				valid_position = false
				break

		attempts += 1

	# Si no encontramos espacio, no crear otro objeto
	if not valid_position:
		return

	var spawn_type = randi() % 10

	match spawn_type:
		0, 1, 2:
			objectInstance = arbusto.instance()
		3, 4, 5:
			objectInstance = lago.instance()
		6, 7, 8:
			objectInstance = roca.instance()
		9:
			if life < 3:
				objectInstance = healing_fish.instance()
			else:
				objectInstance = arbusto.instance()

	objectInstance.position = Vector2(x, y)
	obstacles.add_child(objectInstance)


func _on_DamageTimer_timeout():
	pass


func flicker():
	for i in range(3):
		gatito.visible = false
		yield(get_tree().create_timer(0.1), "timeout")
		gatito.visible = true
		yield(get_tree().create_timer(0.1), "timeout")


func heal():
	if life < 3:
		life += 1

		if life == 2:
			fish2.texture = preload("res://Sprites/life_full.png")
		elif life == 3:
			fish1.texture = preload("res://Sprites/life_full.png")