extends CharacterBody2D

@export var speed: float = 300.0             # Base speed of the enemy
@export var missile_scene: PackedScene       # The missile (seeking missile) scene resource
@export var fire_range: float = 400.0        # Distance within which the enemy will fire
@export var shooting_cooldown: float = 2.0   # Time between missile shots

var can_shoot: bool = true                # Whether the enemy can currently shoot
var player_ref: Node2D = null                # Reference to the player
var direction: Vector2 = Vector2.ZERO        # Movement direction

func _ready() -> void:
	randomize_movement()
	add_to_group("enemies")
	
func _physics_process(delta: float) -> void:
	# Try to get the player reference if we don't have it yet.
	if not player_ref:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0]
	
	if player_ref:
		var to_player = player_ref.global_position - global_position
		var distance = to_player.length()
		if distance <= fire_range:
			direction = to_player.normalized()
			velocity = Vector2.ZERO
			if can_shoot:
				shoot_missile()
		else:
			# Out of range: resume normal movement (chasing or random movement).
			velocity = direction * speed
	else:
		velocity = direction * speed
		
	move_and_slide()
	wrap_around_screen()
	handle_movements(delta)
	

func handle_movements(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		var body = collision.get_collider()
		if body and body.is_in_group("player"):
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
	# Choose a random direction.
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

func _die() -> void:
	# Optionally, spawn a coin when the enemy dies.
	if get_parent().has_method("spawn_coin"):
		get_parent().spawn_coin(global_position)
	queue_free()

func shoot_missile() -> void:
	if missile_scene and player_ref:
		print("Shooting")
		can_shoot = false
		var missile = missile_scene.instantiate()
		get_parent().add_child(missile)
		missile.global_position = global_position
		missile.start(global_transform, player_ref)
		await get_tree().create_timer(shooting_cooldown).timeout
		can_shoot = true
	else:
		print("Nope - missing scene or player")
		
