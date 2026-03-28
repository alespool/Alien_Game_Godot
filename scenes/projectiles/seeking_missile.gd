extends Area2D

@export var speed: float = 250.0
@export var steer_force: float = 150.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

func start(_transform, _target):
	print("Missile start() called, monitoring disabled")
	target = _target
	global_transform = _transform
	velocity = (target.global_position - global_position).normalized() * speed;
	monitoring = false
	set_deferred("monitoring", true)
	
func _physics_process(delta: float) -> void:
	acceleration = seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle() + PI/2;
	position += velocity * delta
	
func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.global_position - global_position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _on_missile_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		return
	if body.is_in_group("player"):
		body.take_damage()
	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()

func _ready():
	await get_tree().create_timer(3.0).timeout;
	queue_free();
