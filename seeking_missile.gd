#extends Area2D
#
#@export var speed: float = 350.0
#@export var steer_force: float = 50.0
#@export var max_lifetime: float = 5.0
#
#var velocity = Vector2.ZERO
#var acceleration = Vector2.ZERO
#var target = null
#var lifetime: float = 0.0
#
#func start(_transform: Transform2D, _target: Node2D) -> void:
	#target = _target
	#global_transform = _transform
	#velocity = transform.x * speed
	#$Lifetime.wait_time = max_lifetime
	#$Lifetime.start()
#
#func _physics_process(delta: float) -> void:
	#lifetime += delta
	#acceleration = seek()
	#velocity += acceleration * delta
	#velocity = velocity.limit_length(speed)
	#position += velocity * delta
	#rotation = velocity.angle()
#
	##acceleration = seek()
	##velocity += acceleration * delta
	##velocity = velocity.limit_length(speed)
	##rotation = velocity.angle()
	##position += velocity * delta
	#
#func seek() -> Vector2:
	#if target and is_instance_valid(target):
		#var desired = (target.global_position - global_position).normalized() * speed
		#var steer = (desired - velocity)
		#return steer.normalized() * min(steer_force, steer.length())
	#return Vector2.ZERO
#
	##if target:
		##var desired = (target.global_position - global_position).normalized() * speed
		##var steer = desired - velocity
		### Only normalize if steer is non-zero:
		##if steer.length() > 0:
			##steer = steer.normalized() * steer_force
		##return steer
	##return Vector2.ZERO
#
#func _on_body_entered(body: Node2D) -> void:
	#if body.is_in_group("player"):
		#body.take_damage()
	#queue_free()
#
#func _on_missile_body_entered(body: Node2D) -> void:
	#queue_free()
#
#func _on_lifetime_timeout() -> void:
	#queue_free()
#

extends Area2D

@export var speed: float = 350.0
@export var steer_force: float = 50.0

var velocity = Vector2.ZERO
var acceleration = Vector2.ZERO
var target = null

func start(_transform, _target):
	target = _target
	global_transform = _transform
	velocity = transform.x * speed
	
func _physics_process(delta: float) -> void:
	acceleration += seek()
	velocity += acceleration * delta
	velocity = velocity.limit_length(speed)
	rotation = velocity.angle()
	position += velocity * delta
	
func seek():
	var steer = Vector2.ZERO
	if target:
		var desired = (target.position - position).normalized() * speed
		steer = (desired - velocity).normalized() * steer_force
	return steer

func _on_missile_body_entered(body: Node2D) -> void:
	queue_free()

func _on_lifetime_timeout() -> void:
	queue_free()
