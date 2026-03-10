extends Node
class_name BattleManager

## Voidrift Tactics - Core Battle Manager
## Author: Mykasia Simpkins
## GitHub: https://github.com/simpkinsmykasia70-cell

enum TurnPhase { PLAYER_TURN, ENEMY_TURN, BATTLE_END }

@export var grid_width: int = 16
@export var grid_height: int = 12
@export var max_turns: int = 30

var current_phase: TurnPhase = TurnPhase.PLAYER_TURN
var turn_number: int = 1
var selected_unit: Unit = null
var player_units: Array[Unit] = []
var enemy_units: Array[Unit] = []

var grid_manager: GridManager
var fog_of_war: FogOfWar
var enemy_ai: EnemyAI
var combat_calc: CombatCalculator

signal turn_started(phase: TurnPhase, turn: int)
signal unit_selected(unit: Unit)
signal unit_moved(unit: Unit, from: Vector2i, to: Vector2i)
signal combat_resolved(attacker: Unit, defender: Unit, damage: int)
signal battle_ended(player_won: bool)

func _ready() -> void:
	grid_manager = $GridManager
	fog_of_war = $FogOfWar
	enemy_ai = $EnemyAI
	combat_calc = $CombatCalculator
	
	grid_manager.initialize(grid_width, grid_height)
	_start_turn(TurnPhase.PLAYER_TURN)

func _start_turn(phase: TurnPhase) -> void:
	current_phase = phase
	turn_started.emit(phase, turn_number)
	
	match phase:
		TurnPhase.PLAYER_TURN:
			_refresh_player_units()
			fog_of_war.update(player_units)
		TurnPhase.ENEMY_TURN:
			await _run_enemy_turn()
			_advance_turn()

func _refresh_player_units() -> void:
	for unit in player_units:
		unit.reset_actions()

func _run_enemy_turn() -> void:
	for enemy in enemy_units:
		if not enemy.is_alive():
			continue
		var action = enemy_ai.decide_action(enemy, player_units, grid_manager)
		await _execute_action(enemy, action)
		await get_tree().create_timer(0.4).timeout

func _execute_action(unit: Unit, action: Dictionary) -> void:
	match action.type:
		"move":
			await move_unit(unit, action.target_cell)
		"attack":
			resolve_combat(unit, action.target_unit)
		"wait":
			unit.end_turn()

func move_unit(unit: Unit, target_cell: Vector2i) -> void:
	var path = grid_manager.get_path(unit.grid_pos, target_cell)
	var from = unit.grid_pos
	for cell in path:
		unit.grid_pos = cell
		unit.global_position = grid_manager.cell_to_world(cell)
		await get_tree().create_timer(0.08).timeout
	unit_moved.emit(unit, from, target_cell)

func resolve_combat(attacker: Unit, defender: Unit) -> void:
	var damage = combat_calc.calculate(attacker, defender)
	defender.take_damage(damage)
	combat_resolved.emit(attacker, defender, damage)
	
	if not defender.is_alive():
		_remove_unit(defender)
	_check_battle_end()

func _remove_unit(unit: Unit) -> void:
	player_units.erase(unit)
	enemy_units.erase(unit)
	unit.queue_free()

func _advance_turn() -> void:
	turn_number += 1
	if turn_number > max_turns:
		battle_ended.emit(false)
		return
	_start_turn(TurnPhase.PLAYER_TURN)

func end_player_turn() -> void:
	if current_phase != TurnPhase.PLAYER_TURN:
		return
	_start_turn(TurnPhase.ENEMY_TURN)

func _check_battle_end() -> void:
	if enemy_units.is_empty():
		battle_ended.emit(true)
	elif player_units.is_empty():
		battle_ended.emit(false)
