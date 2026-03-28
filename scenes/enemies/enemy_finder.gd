extends CharacterBody2D

@export var normal_speed: float = 100.0
@export var chase_speed: float = 200.0
@export var chase_radius: float = 500.0

var direction: Vector2 = Vector2.ZERO
var player_ref: Node2D = null

func _ready() -> void:
	add_to_group("enemies")
	randomize_movements()
	
func _physics_process(delta: float) -> void:
	if player_ref:
		var to_player = player_ref.global_position - global_position
		var distance = to_player.length()
		
		if distance <= chase_radius:
			direction = to_player.normalized()
			velocity = direction * chase_speed
		else:
			direction = direction if direction.length() > 0 else Vector2.RIGHT
			velocity = direction * normal_speed
	else:
		direction = direction if direction.length() > 0 else Vector2.RIGHT
		velocity = direction * normal_speed
	
	handle_movements(delta)
	

func handle_movements(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body and body.is_in_group("player"):
			body._on_hit()
			_die()
			
	move_and_slide()
	wrap_around_screen()

#func _physics_process(delta: float) -> void:
	#$EnemyArea.set_radius(chase_radius)
	#if player_ref:
		#var to_player = player_ref.global_position - global_position
		#if to_player.length() <= chase_radius:
			#direction = to_player.normalized()
			#velocity = direction * chase_speed
		#else:
			#velocity = direction * normal_speed
		#
	#else:
		#velocity = direction * normal_speed
		#
	#move_and_slide()
	#wrap_around_screen()
	
func randomize_movements() -> void:
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func wrap_around_screen() -> void:
	var screen_rect = get_viewport_rect().size
	if global_position.x > screen_rect.x:
		global_position.x = 0
	elif global_position.x < 0:
		global_position.x = screen_rect.x
	if global_position.y > screen_rect.y:
		global_position.y = 0
	elif global_position.y < 0:
		global_position.y = screen_rect.y
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_ref:
		player_ref = null
		randomize_movements()

func _die():
	if get_parent().has_method("spawn_coin"):
		get_parent().spawn_coin(position) 
	queue_free() 
