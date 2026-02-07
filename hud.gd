extends Control


@onready var score_label: Label = $ScoreLabel
@onready var message_label: Label = $Message
@onready var bullet_label: Label = $BulletsCount
@onready var message_timer: Timer = $MessageTimer
@onready var start_button: Button = $StartButton
@onready var high_score_label: Label = $HighScoreLabel

signal start_game

func _ready():
	start_button.pressed.connect(_on_start_button_pressed)

func _on_start_button_pressed() -> void:
	start_button.hide()
	start_game.emit()

func show_message(text: String) -> void:
	message_label.text = text
	message_label.show()
	message_timer.start()
	
func show_game_over() -> void:
	show_message("Game Over")
	
	# Wait until the MessageTimer has counted down.
	await message_timer.timeout

	message_label.text = "KILL THE ALIENS"
	message_label.show()
	
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(1.0).timeout
	start_button.show()
	
func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score
	
func update_high_score(score: int) -> void:
	high_score_label.text = "High score: %d" % score

func update_bullets(value: int) -> void:
	bullet_label.text = "Bullets ready: %d" % value

func _on_message_timer_timeout() -> void:
	message_label.hide()
