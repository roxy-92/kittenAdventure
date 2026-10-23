extends Area2D

func _on_HealingFish_body_entered(body):
    if body.name == "gatito":
        body.heal()
        queue_free()