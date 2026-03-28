extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func blitme(self):
	"""Draw the ship at its current location."""
	self.screen.blit(self.image, self.rect)

func update(self, delta_time):
	"""Update the ship's rotation and position."""
	self.rotation.update_rotation()
	self.movement.update_position(delta_time)

func center_ship(self):
	"""Center the ship on the middle of the screen."""
	self.movement.center_entity()

func shield_hit(self):
	"""Handle the ship being hit by an alien."""
	if self.settings.shield_strength > 0:
		self.settings.shield_strength -= 1
	else:
		self.settings.ships_left -= 1
		self.center_ship()
