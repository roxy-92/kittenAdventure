extends KinematicBody2D

var motion = Vector2(100,100) # El movimiento, vector
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
	limit_right = screen_size.x - limit_plus
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
	if Input.is_action_pressed("ui_right"):  # Si pulsa tecla derecha
		motion = Vector2(0,0) # Pongo primero todo el movimiento a 0 para evitar conflictos
		motion.x = speed
		# Posición y movimiento del sprite. Flip gira vertical y horizontalmente el sprite
		gatito.flip_v = false
		gatito.flip_h = false
		gatito.play("Run_Side")		
		
	elif Input.is_action_pressed("ui_left"):  # Si pulsa tecla izquierda
		motion = Vector2(0,0)
		motion.x = -speed
		# Posición y movimiento del sprite.
		gatito.flip_v = false
		gatito.flip_h = true
		gatito.play("Run_Side")
			
	elif Input.is_action_pressed("ui_up"):
		# Si pulsa tecla arriba
		motion = Vector2(0,0)
		motion.y = -speed
		# Posición y movimiento del sprite.
		gatito.flip_v = false
		gatito.flip_h = false
		gatito.play("Run")
		# Comprobación del límite hacia arriba
		#if(self.position.y <= limit_up):
		#	self.position.y = limit_up
		
	elif Input.is_action_pressed("ui_down"):  # Si pulsa tecla abajo
		motion = Vector2(0,0)
		motion.y = 100
		# Posición y movimiento del sprite.
		gatito.flip_v = true
		gatito.flip_h = false
		gatito.play("Run")
	# Comprobación del límite hacia abajo
	elif self.position.y >= limit_down:
		gatito.play("Run")
		self.position.y = limit_down
	# En cualquier otro caso el gatito se quedará quieto y su movimiento pasará a 0 + animacion descanso
	else:
		gatito.play("Idle")
		motion.y = 0
		motion.x = 0
		
	if(self.position.x <= limit_left):
		self.position.x = limit_left
	elif(self.position.x >= limit_right):
		self.position.x = limit_right
		
	# Si el gatito se choca con un obstáculo
	collision = move_and_collide(motion * delta)
	if collision:		
		life = life -1
		gatito.play("Idle")
		restart_position() # Vuelve a su posición original
		if life == 0:
			life = 3
			gatito.play("Idle")
			restart_position()
			gatito.play("Idle")
			get_tree().reload_current_scene()
			get_tree().paused = true			 
	
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
	