extends CharacterBody2D

@export var speed: float = 300.0  # Base speed of the enemy
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	randomize_movement()
	add_to_group("enemies")
	
func _physics_process(delta: float) -> void:
	# Move the enemy in the randomized direction
	velocity = direction * speed
	move_and_slide()

	# Wrap around the screen if the enemy goes out of bounds
	wrap_around_screen()
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body.is_in_group("player"):
			body._on_hit()
			_die()

func wrap_around_screen() -> void:
	var screen_size = get_viewport_rect().size
	if position.x > screen_size.x:
		position.x = 0
	elif position.x < 0:
		position.x = screen_size.x
	if position.y > screen_size.y:
		position.y = 0
	elif position.y < 0:
		position.y = screen_size.y

func randomize_movement() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _die():
	if get_parent().has_method("spawn_coin"):
		get_parent().spawn_coin(position) 
	queue_free() 
