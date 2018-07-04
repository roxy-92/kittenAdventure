extends Camera2D

var camera_position = self.position.x

func _ready():
	set_process(true)
	
func _process(delta):
	self.position.y = self.position.y - 1 