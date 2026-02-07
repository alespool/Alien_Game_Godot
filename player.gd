extends CharacterBody2D
signal hit

# Exported variables for tuning
@export var boost_multiplier: float = 2.0                 # Boost speed multiplier
@export var boost_duration: float = 2.0                   # Boost speed duration
@export var acceleration: float = 1200.0                  # Ship acceleration
@export var max_speed: float = 600.0                      # Ship max speed
@export var friction: float = 0.95                        # Movement friction/drift
@export var rotation_speed: float = 5.0                   # Ship axis rotation speed
@export var mass: float = 1.0                             # Ship weight default to 1
@export var max_health: float = 100.0                     # Ship health
@export var invincibility_duration: float = 1.5           # Ship can't take damage

@export var joystick_rotation_speed: float = 5.0
@export var joystick_deadzone: float = 0.2
@export var bullet_scene: PackedScene

enum UpgradeType {
	SPEED,
	HEALTH,
	SHIELD,
	RAPID_FIRE
}


var upgrades = {
	UpgradeType.SPEED: 0,
	UpgradeType.HEALTH: 0,
	UpgradeType.SHIELD: 0,
	UpgradeType.RAPID_FIRE: 0
}


var is_boosting: bool = false
var is_disabled: bool = false
var boost_timer: float = 0.0
var current_health: float
var is_invincible: bool = false
var flash_timer: float = 0.0

@onready var sprite = $AnimatedSprite2D


func _ready() -> void:
	center_ship_above_bottom()
	add_to_group("player")
	current_health = max_health
	get_parent().get_node("HUD/BottomHUD").update_health_bar(current_health, max_health)

func _process(delta: float) -> void:
	handle_movement(delta)
	handle_boost(delta)
	handle_invincibility(delta)
	handle_rotation()
	handle_wraparound()
	handle_animation()
	
func handle_boost(delta: float) -> void:
	# Handle boost of the speed
	if Input.is_action_just_pressed("boost") and not is_boosting:
		is_boosting = true
		print("Ship speed boosted!")
		boost_timer = boost_duration
	
	if is_boosting:
		boost_timer -= delta
		if boost_timer <= 0:
			is_boosting = false

func handle_movement(delta: float) -> void:
	var input_dir = Vector2.ZERO

	# Get input direction
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
		

	# Normalize input to prevent diagonal speed boost
	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		velocity += input_dir * (acceleration/mass) * delta
		if is_boosting:
			velocity = velocity.limit_length(max_speed * boost_multiplier)
		else:
			velocity = velocity.limit_length(max_speed)  # Apply max speed
	else:
		# Apply friction independently for x and y axes
		velocity *= friction

	# Move the entity
	move_and_slide()

func handle_rotation() -> void:
	var rotation_direction: Vector2
	
	var right_stick_x = Input.get_axis("joypad_right_left", "joypad_right_right")
	var right_stick_y = Input.get_axis("joypad_right_up", "joypad_right_down")
	
	if abs(right_stick_x) > joystick_deadzone || abs(right_stick_y) > joystick_deadzone:
		rotation_direction = Vector2(right_stick_x, right_stick_y).normalized()
	else:
		var mouse_pos = get_global_mouse_position()
		rotation_direction = (mouse_pos - global_position).normalized()
		
	if rotation_direction.length() > 0:
		var target_angle = rotation_direction.angle() + deg_to_rad(90)  # Adjust for sprite orientation
#
		rotation = lerp_angle(rotation, target_angle, rotation_speed * get_process_delta_time())
	

#func handle_rotation() -> void:
	## Rotate towards mouse cursor
	#var mouse_pos = get_global_mouse_position()
	#var direction = (mouse_pos - global_position).normalized()
	#var target_angle = direction.angle() + deg_to_rad(90)  # Adjust for sprite orientation
#
	#rotation = lerp_angle(rotation, target_angle, rotation_speed * get_process_delta_time())
	
	
func handle_wraparound() -> void:
	var screen_rect = get_viewport_rect().size
	
	# Check if ship is out of bounds horizontally
	if global_position.x > screen_rect.x:
		global_position.x = 0 # wrap to the left side
	if global_position.x < 0:
		global_position.x = screen_rect.x  # wrap to the right side
		
	# Check if ship is out of bounds vertically
	if global_position.y > screen_rect.y:
		global_position.y = 0 # wrap to top side
	if global_position.y < 0:
		global_position.y = screen_rect.y # wrap to the bottom side
	
func handle_animation() -> void:
	if velocity.length() > 10:  # Check if the ship is moving
		$AnimatedSprite2D.play("move")
	else:
		$AnimatedSprite2D.stop()

func center_ship_above_bottom() -> void:
	var screen_rect = get_viewport_rect().size
	global_position = Vector2(screen_rect.x / 2, screen_rect.y - 200)  # Adjust 100 as needed

func _input(event: InputEvent) -> void:
		
	if event.is_action_pressed("shoot"):
		var current_bullets  = get_tree().get_nodes_in_group("bullets")
		
		if get_parent().bullets_remaining > 0 and current_bullets.size() < 5:
			_fire_bullet()

func _fire_bullet() -> void:
	get_parent().count_bullets()
	var bullet = preload("res://bullet.tscn").instantiate()
	bullet.global_position = global_position  # Spawn the bullet at the ship's position
	get_parent().add_child(bullet)  # Add the bullet to the scen
		

func _on_hit(amount: float = 10.0) -> void:
	if is_invincible or is_disabled:
		return
	
	current_health = max(0, current_health - amount)
	get_parent().get_node("HUD/BottomHUD").update_health_bar(current_health, max_health)
	
	# Start invincibility period
	is_invincible = true
	flash_timer = invincibility_duration
	
	create_damage_flash()
	hit.emit()
	
	if current_health <= 0:
		get_parent().game_over()
		
func create_damage_flash() -> void:
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(sprite, "modulate", Color(1 ,1 ,1 ,1), 0.1)
	
func handle_invincibility(delta: float) -> void:
	if is_invincible:
		flash_timer -= delta
		sprite.modulate.a = 0.5 if int(flash_timer  * 10) % 2 == 0 else 1.0
		
		if flash_timer <= 0:
			is_invincible = false
			sprite.modulate = Color(1, 1, 1, 1)
			
func start() -> void:
	show()
	$CollisionShape2D.disabled = false
	current_health = max_health
	get_parent().get_node("HUD/BottomHUD").update_health_bar(current_health, max_health)
	
func disable() -> void:
	is_disabled = true
	visible = false

func enable() -> void:
	is_disabled = false
	visible = true
	$AnimatedSprite2D.modulate = Color(1, 1, 1, 1)
	is_invincible = true
	flash_timer = invincibility_duration
	
func reset_position() -> void:
	global_position = get_viewport_rect().size / 2

func apply_upgrades(type: UpgradeType) -> void:
	upgrades[type] += 1
	match type:
		UpgradeType.SPEED:
			max_speed += 50.0
			acceleration += 100.0
		UpgradeType.HEALTH:
			max_health += 25.0
			current_health = max_health
			get_parent().get_node("HUD/BottomHUD").update_health_bar(current_health, max_health)
		UpgradeType.SHIELD:
			invincibility_duration += 2.5
		UpgradeType.RAPID_FIRE:
			pass
		
