extends Node

const SAVE_PATH = "res://save_files//spacegame.save"

var game_data = {
	"high_score" : 0,
	"unlocked_upgrades": []
}

func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_var(game_data)
	
func load_game() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		game_data = file.get_var()
