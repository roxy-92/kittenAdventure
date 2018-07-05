extends Camera2D

func _ready():
	set_process(true)
	
func _process(delta):
	self.position.y = self.position.y - delta * 60 