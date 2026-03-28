# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository. You have the task of helping me develop this project, and not to write it all by yourself. I want you to guide me to understand how to do the things I want to do, and use metaphors to make me understand better. Avoid writing comments in the code.

## Project Overview

**Alien Invasion** — a 2D space shooter built with Godot 4.6. The player controls a spaceship at the bottom of the screen, shooting upward at incoming aliens. Features multiple enemy types, a coin-based upgrade system, and persistent high scores.

**Viewport:** 2000×1500 px | **Main Scene:** `game_world.tscn`

## Running the Game

Open the project in Godot 4.x and press F5, or run from the command line:
```
godot --path /path/to/project
```

Run a specific scene:
```
godot scene_name.tscn
```

## Folder Structure

```
scenes/
  game_world.tscn          # Root scene
  gameworld.gd             # Main game controller

  enemies/
    enemy.tscn / .gd       # Basic enemy: random movement
    enemy_finder.tscn / .gd  # Chaser enemy: pursues player within 500px
    enemy_shooter.tscn / .gd # Shooter enemy: fires missiles when player within 400px

  player/
    player.tscn / .gd      # Player ship controller
    ships_human.gd         # Unused placeholder

  projectiles/
    bullet.tscn / .gd      # Player bullets: max 5 active, fires toward mouse
    seeking_missile.tscn / .gd  # Enemy missiles: boids-style seek steering

  ui/
    hud.tscn / .gd         # Top HUD: score, high score, bullets, messages, start button
    bottom_hud.tscn / .gd  # Bottom HUD: health bar, coin counter, upgrade buttons

  objects/
    coin.tscn / .gd        # Currency pickup: dropped by dead enemies

  systems/
    save_manager.gd        # Persistent data (high scores, save file management)

  data/
    # Placeholder for future data structures

assets/
  bullet.png
  first_background.png
  first_alien_cut.png
  second_alien_cut.png
  third_alien_cut.png
  ships_human.png / ships_human_move.png
  Missile05.png / seeking_missile.png
  MonedaD.png / MonedaP.png / MonedaR.png  # Coin frames
  upgrades/
    speed.png / speed_smaller.png
    health.png / health_smaller.png
    shield.png / shield_smaller.png
    rapid_fire.png / rapid_fire_smaller.png

fonts/
  Xolonium-Regular.ttf

sounds/
  mainMenu.mp3

save_files/
  spacegame.save          # Persisted high score
```

## Scene Graph (Runtime)

- **game_world.tscn** (`gameworld.gd`) — root scene, game controller
  - **player.tscn** (`player.gd`) — player ship at bottom center
  - **hud.tscn** — CanvasLayer UI
    - **TopHUD** (`hud.gd`) — score, high score, bullets, messages, start button
    - **BottomHUD** (`bottom_hud.gd`) — health bar, coin counter, upgrade buttons
  - **EnemyPath** (Path2D + PathFollow2D) — enemy spawn positions along top edge
  - **SaveManager** (`save_manager.gd`) — persistent data

## Entity Reference

### Enemy Types (spawned by gameworld.gd with weighted random selection)
| Scene | Script | Behavior |
|---|---|---|
| `scenes/enemies/enemy.tscn` | `enemy.gd` | Random movement, wraps screen edges |
| `scenes/enemies/enemy_finder.tscn` | `enemy_finder.gd` | Wanders; chases player within 500px |
| `scenes/enemies/enemy_shooter.tscn` | `enemy_shooter.gd` | Fires seeking missiles when player within 400px |

### Projectiles
- **`scenes/projectiles/bullet.tscn`** (`bullet.gd`) — player bullets, fire toward mouse, max 5 active
- **`scenes/projectiles/seeking_missile.tscn`** (`seeking_missile.gd`) — enemy projectile with boids-style seek steering

### Key Systems

**Game State Flow (gameworld.gd):**
1. Player presses Start → 2s StartTimer → EnemyTimer begins spawning
2. Enemies spawn up to `max_enemies` (10), killed enemies drop coins
3. Player health → 0 → game over, high score saved

**Upgrade System:** Four purchasable upgrades (speed, health, shield, rapid_fire) bought with coins via `purchase_upgrade(type)` in `gameworld.gd`. Costs defined in `upgrade_costs` dict. Rapid fire is not yet implemented.

**Persistence:** `save_manager.gd` saves to `res://save_files/spacegame.save` — stores high score. Upgrade persistence is not yet implemented.

**Physics Layers:** Layer 2 = Bullets, Layer 3 = Enemies

### Input Bindings
- Move: WASD / Arrow keys / Joypad
- Boost (2× speed, 2s): Shift / Joypad LB
- Shoot (toward mouse): Spacebar / Joypad RT
- Start: Space / Enter / Joypad A
- Quit: Q / Joypad B

## Known Gaps / In-Progress
- Rapid Fire upgrade is a placeholder (no effect)
- Seeking missile has no timeout (lives indefinitely until hitting something)
- Upgrade purchases are not persisted to disk
- Difficulty does not scale automatically (`max_enemies` is static)
