extends Node

@export var enemy_scene: PackedScene
@export var chasing_enemy_scene: PackedScene
@export var shooting_enemy_scene: PackedScene
@export var chase_enemy_chance: float = 0.3
@export var coin_scene: PackedScene 

var score: int = 0
var bullets_remaining: int = 5
var max_enemies: int = 10
var is_game_over: bool = false
var high_score: int = 0
var coin_amount: int = 0

var upgrade_costs = {
	"speed": 10,
	"health": 15,
	"shield": 20,
	"rapid_fire": 25
}

var enemy_types = {
	"basic": {"scene": null, "weight": 1},
	"chaser": {"scene": null, "weight": 1},
	"shooter": {"scene": null, "weight": 98}
	# Add new types here in the future
}

@onready var save_manager = $SaveManager
@onready var hud = $HUD/TopHUD       # Reference to TopHUD (your main HUD)
@onready var bottom_hud = $HUD/BottomHUD  # Reference to BottomHUD (for coins/upgrades)

func _ready() -> void:
	randomize() 
	
	enemy_types["basic"]["scene"] = enemy_scene
	enemy_types["chaser"]["scene"] = chasing_enemy_scene
	enemy_types["shooter"]["scene"] = shooting_enemy_scene
	
	save_manager.load_game()
	high_score = save_manager.game_data["high_score"]
	hud.update_high_score(high_score)
	bottom_hud.update_upgrade_costs(upgrade_costs)
	hud.start_game.connect(_on_start_game)

func _on_start_game() -> void:
	new_game()

func _process(delta: float) -> void:
	handle_reload()

func handle_reload() -> void:
	# Auto reload if the player shot all bullets available
	if bullets_remaining == 0 and get_tree().get_nodes_in_group("bullets").size() == 0:
		reload_bullets()

func game_over() -> void:
	is_game_over = true
	$EnemyTimer.stop()
	$RespawnTimer.stop()
	$Player.disable()
	hud.show_game_over()
	$Music.stop()
	reset_score()

func new_game() -> void:
	is_game_over = false
	score = 0
	$Player.current_health = $Player.max_health
	$Player.start()
	bottom_hud.update_health_bar($Player.current_health, $Player.max_health)
	reload_bullets()
	$StartTimer.start()
	$EnemyTimer.wait_time = 2.0  # Spawn an enemy every 2 seconds
	$Music.play()
	hud.update_score(score)
	hud.show_message("Get Ready")
	bottom_hud.update_coins(coin_amount)

func increase_score() -> void:
	score += 1
	if score > high_score:
		high_score = score
		save_manager.game_data["high_score"] = high_score
		save_manager.save_game()
		hud.update_high_score(high_score)
	hud.update_score(score)
	
func reset_score() -> void:
	score = 0
	hud.update_score(score)

func count_bullets() -> void:
	bullets_remaining = max(bullets_remaining - 1, 0)
	hud.update_bullets(bullets_remaining)
	
func reload_bullets() -> void:
	bullets_remaining = 5
	hud.update_bullets(bullets_remaining)

func _on_start_timer_timeout() -> void:
	$EnemyTimer.start()

func _on_enemy_timer_timeout() -> void:
	#var enemy = enemy_scene.instantiate()
	#if is_game_over:
		#enemy.queue_free()
		#return
	#
	#if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		#var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
		#enemy_spawn_location.progress_ratio = randf()
		#enemy.position = enemy_spawn_location.position
		#enemy.rotation = randf_range(0, 2 * PI)
		#add_child(enemy)
		
	if get_tree().get_nodes_in_group("enemies").size() < max_enemies:
		# Choose enemy type based on weights
		var enemy_scene = choose_enemy_type()

		var enemy_instance = enemy_scene.instantiate()
		var enemy_spawn_location = $EnemyPath/EnemySpawnLocation
		enemy_spawn_location.progress_ratio = randf()
		enemy_instance.position = enemy_spawn_location.position
		enemy_instance.rotation = randf_range(0, 2 * PI)
		add_child(enemy_instance)

		if is_game_over:
			enemy_instance.queue_free()
			return

func choose_enemy_type() -> PackedScene:
	# Calculate total weight
	var total_weight = 0
	for type in enemy_types:
		total_weight += enemy_types[type]["weight"]

	# Roll for enemy type
	var roll = randf() * total_weight
	var current_weight = 0

	for type in enemy_types:
		current_weight += enemy_types[type]["weight"]
		if roll <= current_weight:
			return enemy_types[type]["scene"]

	# Fallback
	return enemy_types["basic"]["scene"]


func _on_ship_hit() -> void:
	if is_game_over:
		return
			
	if not is_game_over:
		$Player.disable()
		$RespawnTimer.start()

func _on_respawn_timer_timeout() -> void:
	$Player.enable()
	$Player.reset_position()

func purchase_upgrade(upgrade_type: String) -> bool:
	var cost = upgrade_costs[upgrade_type]

	if coin_amount >= cost:
		coin_amount -= cost 
		bottom_hud.update_coins(coin_amount)

		# Apply the upgrade to the player
		match upgrade_type:
			"speed": $Player.apply_upgrades($Player.UpgradeType.SPEED)
			"health": $Player.apply_upgrades($Player.UpgradeType.HEALTH)
			"shield": $Player.apply_upgrades($Player.UpgradeType.SHIELD   )
			"rapid_fire": $Player.apply_upgrades($Player.UpgradeType.RAPID_FIRE)

		bottom_hud.update_upgrade_costs(upgrade_costs)
		return true
	return false

func collect_coin() -> void:
	coin_amount += 1
	bottom_hud.update_coins(coin_amount)

func spawn_coin(position: Vector2) -> void:
	var coin = coin_scene.instantiate()
	coin.global_position = position
	add_child(coin)
