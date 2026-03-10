extends Node
class_name EventLogger

## Godot AI Asset Builder - Event Logger
## Records all simulation events for ML training datasets
## Author: Mykasia Simpkins
## GitHub: https://github.com/simpkinsmykasia70-cell

@export var output_path: String = "res://exports/logs/"
@export var auto_save_interval: float = 30.0
@export var max_events_per_file: int = 10000

var _events: Array = []
var _session_id: String = ""
var _start_time: int = 0
var _event_count: int = 0

signal event_logged(event: Dictionary)
signal log_saved(filepath: String)

func _ready() -> void:
	_session_id = _generate_session_id()
	_start_time = Time.get_ticks_msec()
	DirAccess.make_dir_recursive_absolute(output_path)
	
	# Auto-save timer
	var timer = Timer.new()
	timer.wait_time = auto_save_interval
	timer.timeout.connect(save_log)
	add_child(timer)
	timer.start()
	
	print("[EventLogger] Session started: ", _session_id)

func log_event(event_type: String, data: Dictionary = {}) -> void:
	var event = {
		"id": _event_count,
		"session": _session_id,
		"type": event_type,
		"timestamp_ms": Time.get_ticks_msec() - _start_time,
		"timestamp_iso": Time.get_datetime_string_from_system(),
		"data": data
	}
	_events.append(event)
	_event_count += 1
	event_logged.emit(event)
	
	if _events.size() >= max_events_per_file:
		save_log()
		_events.clear()

func log_npc_action(npc_id: String, action: String, position: Vector2, target = null) -> void:
	log_event("npc_action", {
		"npc_id": npc_id,
		"action": action,
		"position": { "x": position.x, "y": position.y },
		"target": str(target) if target else null
	})

func log_combat(attacker_id: String, defender_id: String, damage: int, result: String) -> void:
	log_event("combat", {
		"attacker": attacker_id,
		"defender": defender_id,
		"damage": damage,
		"result": result
	})

func log_state_change(entity_id: String, old_state: String, new_state: String) -> void:
	log_event("state_change", {
		"entity": entity_id,
		"from": old_state,
		"to": new_state
	})

func save_log() -> void:
	if _events.is_empty():
		return
	
	var filename = output_path + "session_%s_%d.json" % [_session_id, Time.get_ticks_msec()]
	var file = FileAccess.open(filename, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify({
			"session_id": _session_id,
			"total_events": _event_count,
			"events": _events
		}, "\t"))
		file.close()
		log_saved.emit(filename)
		print("[EventLogger] Saved: ", filename)

func _generate_session_id() -> String:
	return "%d_%d" % [Time.get_unix_time_from_system(), randi() % 9999]

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_log()
