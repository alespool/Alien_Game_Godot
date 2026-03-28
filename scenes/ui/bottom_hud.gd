extends Control

# References to nodes in the BottomHUD
@onready var health_bar: ProgressBar = $HealthBar
@onready var coin_amount: Label = $CoinCounter/CoinAmount

# Upgrade buttons (TextureButton nodes)
@onready var speed_upgrade_btn: TextureButton = $UpgradeBar/Speed
@onready var health_upgrade_btn: TextureButton = $UpgradeBar/Health
@onready var shield_upgrade_btn: TextureButton = $UpgradeBar/Shield
@onready var rapid_fire_upgrade_btn: TextureButton = $UpgradeBar/RapidFire

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func update_health_bar(current: float, maximum: float) -> void:
	if not health_bar:  # Add error checking
		push_error("Health bar not found!")
		return
	
	health_bar.value = (current/maximum) * 100

	var health_percent = current/maximum
	if health_percent > 0.7:
		health_bar.modulate = Color(0, 1, 0)
	elif health_percent > 0.3:
		health_bar.modulate = Color(1, 1, 0)
	else:
		health_bar.modulate = Color(1, 0 ,0)

func update_coins(coins: int) -> void:
	coin_amount.text = "Coins: " + str(coins)
	
func update_upgrade_costs(costs: Dictionary) -> void:
	# Expects a dictionary 
	$UpgradeBar/Speed/Container/Value.text = str(costs["speed"])
	$UpgradeBar/Health/Container/Value.text = str(costs["health"])
	$UpgradeBar/Shield/Container/Value.text = str(costs["shield"])
	$UpgradeBar/RapidFire/Container/Value.text = str(costs["rapid_fire"])
	
func _on_speed_pressed() -> void:
	if get_parent().get_parent().purchase_upgrade("speed"):
		speed_upgrade_btn._on_pressed()

func _on_health_pressed() -> void:
	if get_parent().get_parent().purchase_upgrade("health"):
		health_upgrade_btn._on_pressed()

func _on_shield_pressed() -> void:
	if get_parent().get_parent().purchase_upgrade("shield"):
		shield_upgrade_btn._on_pressed()

func _on_rapid_fire_pressed() -> void:
	if get_parent().get_parent().purchase_upgrade("rapid_fire"):
		rapid_fire_upgrade_btn._on_pressed()

func _input(event):
	if event is InputEventKey and event.pressed and not event.is_echo():
		match event.keycode:
			KEY_F1: _on_speed_pressed();
			KEY_F2: _on_health_pressed();
			KEY_F3: _on_shield_pressed();
			KEY_F4: _on_rapid_fire_pressed();
