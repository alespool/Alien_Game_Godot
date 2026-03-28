extends Area2D

@onready var animation_player = $AnimationPlayer

func _ready() -> void:
	# Start idle/spinning animation
	animation_player.play("idle") 
	
	# Play a spawn animation: scale from (0,0) to (1,1)
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.2).from(Vector2(0, 0))

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Call the parent's collect_coin() if it exists.
		if get_parent().has_method("collect_coin"):
			get_parent().collect_coin()
		
		# Play collect animation: scale down to (0,0) then free the coin.
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(0, 0), 0.2)
		tween.tween_callback(Callable(self, "queue_free"))
