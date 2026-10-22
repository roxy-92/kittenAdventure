extends Camera2D

var camera_started = false

func _ready():
    set_process(true)

func _process(delta):
    if not camera_started:
        if Input.is_action_pressed("ui_up") or \
        Input.is_action_pressed("ui_down") or \
        Input.is_action_pressed("ui_left") or \
        Input.is_action_pressed("ui_right"):
            camera_started = true

    if camera_started:
        self.position.y = self.position.y - delta * 60