extends Area2D

@export var bullet_acceleration: float = 1500.0     # Bullet acceleration (unused)
@export var bullet_speed: float = 1500.0             # Bullet speed
@export var bullet_mass: float = 1.0                # Bullet weight/mass (unused)
@export var bullet_lifetime: float = 5.0            # Bullet lifetime
@export var trail_length: float = 10.0              # Number of points in the trail
@export var bullet_limit: int = 5               

var direction := Vector2.ZERO
var timer: float = 0.0
var last_position := Vector2.ZERO                    # Track the last position for wraparound detection

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("bullets")
	handle_direction()
	last_position = global_position   # Initialize the last position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_movement(delta)
	handle_bullet_lifetime(delta)
	handle_boundaries()
	#handle_wraparound()
	
	
func _exit_tree() -> void:
	remove_from_group("bullets")

	
func handle_bullet_lifetime(delta: float) -> void:
	# Destroy bullet if it lasts longer than its lifetime
	timer += delta
	if timer >= bullet_lifetime:
		queue_free() 
	
func handle_movement(delta: float) -> void:
	last_position = global_position   # Store the current position before moving
	global_position += direction * bullet_speed * delta
	
func handle_direction() -> void:
	# Rotate towards the mouse cursor
	var mouse_pos = get_global_mouse_position()
	direction = (mouse_pos - global_position).normalized()
	rotation = direction.angle() + deg_to_rad(90)  # Adjust for sprite orientation

func handle_boundaries() -> void:
	# Remove the bullet if it goes outside the screen boundaries
	var screen_size = get_viewport_rect().size
	if global_position.x > screen_size.x or global_position.x < 0 or global_position.y > screen_size.y or global_position.y < 0:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	# Handle collisions with other bodies (e.g. enemies)
	if body.is_in_group("enemies"):
		body._die() # Destroys the bullet
		queue_free() 
		get_parent().increase_score()

#func handle_wraparound() -> void:
	#var screen_rect = get_viewport_rect().size
	#var wrapped = false
	#
	#if global_position.x > screen_rect.x:
		#global_position.x = 0
		#wrapped = true
	#elif global_position.x < 0:
		#global_position.x = screen_rect.x
		#wrapped = true
		#
	#if global_position.y > screen_rect.y:
		#global_position.y = 0
		#wrapped = true
	#elif global_position.y < 0:
		#global_position.y = screen_rect.y
		#wrapped = true
#
	#if wrapped:
		#$Sprite2D/Line2D.split_trail()
