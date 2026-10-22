extends KinematicBody2D

var motion = Vector2(0, 0) # El movimiento, vector
var start_position = Vector2(512,550) # Posición inicial
var collision = null # Si ha chocado con obstáculo
var screen_size # Tamaño de la ventana
var kitten_speed = 12000 # Velocidad del personaje
# Límites del movimiento del personaje
var limit_left = 0
var limit_right = 0
var limit_up = 0
var limit_down = 0
var limit_plus = 100
# Vida total del gato
var life = 3
var can_take_damage = true
onready var fish1 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish1")
onready var fish2 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish2")
onready var fish3 = get_parent().get_parent().get_node("CanvasLayer/GUI/lives/Fish3")

var fish_empty = preload("res://Sprites/life_empty.png")
# Posición y de la cámara, pues se mueve.
var cameraPosition_y = 0
# Obtención del sprite gatito
onready var gatito = $sprite_gatito
# Cargamos los obstáculos para después usarlos y repetirlos por el mapa
var objectInstance

onready var lago = preload('lago.tscn')
onready var arbusto = preload('arbusto.tscn')
onready var roca = preload('roca.tscn')

# Función que se ejecuta primero nada mas arrancar el juego
func _ready():	
	if life > 0:
		get_tree().paused = false
	# Obtención del tamaño de la ventana
	screen_size = get_viewport_rect().size
	# Inicialización de los límites del movimiento del gatito en la pantalla.
	limit_down = screen_size.y - limit_plus
	limit_up = limit_plus
	limit_left = limit_plus
	limit_right = 1024 - limit_plus
	# Se reinicia la posición del gatito al comenzar
	self.position =  Vector2(512,400)
	set_process(true)
	
func _physics_process(delta):
	
	
	var speed = self.kitten_speed * delta;
	cameraPosition_y = get_parent().get_node("Camera2D").get_camera_position().y
	limit_down = start_position.y + cameraPosition_y
		
	if (int(cameraPosition_y) % 200 == 0):
		# generamos obstáculos
		random_obstaculos(cameraPosition_y-100)

	# Controles, movimiento del personaje
	motion = Vector2(0, 0)
	
	if Input.is_action_pressed("ui_right"):
	    motion.x = speed
	    gatito.flip_v = false
	    gatito.flip_h = false
	    gatito.play("Run_Side")
	
	elif Input.is_action_pressed("ui_left"):
	    motion.x = -speed
	    gatito.flip_v = false
	    gatito.flip_h = true
	    gatito.play("Run_Side")
	
	elif Input.is_action_pressed("ui_up"):
	    motion.y = -speed
	    gatito.flip_v = false
	    gatito.flip_h = false
	    gatito.play("Run")
	
	elif Input.is_action_pressed("ui_down"):
	    motion.y = 100
	    gatito.flip_v = true
	    gatito.flip_h = false
	    gatito.play("Run")
	
	else:
	    gatito.play("Idle")
	
	# Comprobación del límite hacia abajo
	if self.position.y >= limit_down:
	    self.position.y = limit_down
		
	if(self.position.x <= limit_left):
		self.position.x = limit_left
	elif(self.position.x >= limit_right):
		self.position.x = limit_right
		
	# Si el gatito se choca con un obstáculo
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
	
# Reinicia al gatito en la posición de inicio y en postura quieto
func restart_position():
		self.position = Vector2(start_position.x, start_position.y + cameraPosition_y)
		gatito.play("Idle")
				
func random_obstaculos(y):
	
	var x = randi()%800+240;	
	
	match randi() % 3:
		0:
			objectInstance = arbusto.instance()
		1:
			objectInstance = lago.instance()
		2:
			objectInstance = roca.instance()
			
	objectInstance.position = Vector2(x,y)
	get_parent().get_parent().get_node("obstaculos").add_child(objectInstance)
	

func _on_DamageTimer_timeout():
	pass # replace with function body

func flicker():
    for i in range(3):
        gatito.visible = false
        yield(get_tree().create_timer(0.1), "timeout")
        gatito.visible = true
        yield(get_tree().create_timer(0.1), "timeout")