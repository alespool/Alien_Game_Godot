extends TextureButton
class_name AbilityButton

@onready var time_label = $Container/Value

@export var cooldown = 2.0

func _ready() -> void:
	time_label.hide()
	$Sweep.value = 0
	$Sweep.texture_progress = texture_normal
	$Timer.wait_time = cooldown
	set_process(false)
	
func _process(delta: float) -> void:
	time_label.text = "%3.1f" % $Timer.time_left
	$Sweep.value = int(($Timer.time_left / cooldown) * 100)

func _on_pressed() -> void:
	disabled = true
	set_process(true)
	$Timer.start()
	time_label.show()

func _on_timer_timeout() -> void:
	print("ability ready")
	$Sweep.value = 0
	disabled = false
	time_label.hide()
	set_process(false)
