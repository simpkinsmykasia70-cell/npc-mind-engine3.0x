extends Node

## PixelShift UI Kit - Global UI Manager (Autoload)
## Author: Mykasia Simpkins
## GitHub: https://github.com/simpkinsmykasia70-cell

enum ToastType { INFO, SUCCESS, WARNING, ERROR }
enum Theme { DARK, LIGHT, HIGH_CONTRAST }

const TOAST_COLORS = {
	ToastType.INFO:    Color(0.2, 0.5, 0.9),
	ToastType.SUCCESS: Color(0.2, 0.75, 0.4),
	ToastType.WARNING: Color(0.95, 0.7, 0.1),
	ToastType.ERROR:   Color(0.9, 0.25, 0.25)
}

var current_theme: Theme = Theme.DARK
var _toast_queue: Array = []
var _toast_active: bool = false
var _modal_open: bool = false

signal theme_changed(new_theme: Theme)
signal modal_closed(choice: String)
signal toast_shown(message: String)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

## === TOAST NOTIFICATIONS ===

func toast(message: String, type: ToastType = ToastType.INFO, duration: float = 2.5) -> void:
	_toast_queue.append({ "message": message, "type": type, "duration": duration })
	if not _toast_active:
		_show_next_toast()

func _show_next_toast() -> void:
	if _toast_queue.is_empty():
		_toast_active = false
		return
	
	_toast_active = true
	var data = _toast_queue.pop_front()
	var toast_node = _create_toast(data)
	get_tree().root.add_child(toast_node)
	toast_shown.emit(data.message)
	
	await get_tree().create_timer(data.duration).timeout
	_animate_out(toast_node)
	await get_tree().create_timer(0.3).timeout
	toast_node.queue_free()
	_show_next_toast()

func _create_toast(data: Dictionary) -> Control:
	var panel = PanelContainer.new()
	var label = Label.new()
	label.text = data.message
	panel.add_child(label)
	panel.modulate = TOAST_COLORS[data.type]
	panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	panel.position = Vector2(-320, -80)
	
	var tween = panel.create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2).from(0.0)
	return panel

func _animate_out(node: Control) -> void:
	var tween = node.create_tween()
	tween.tween_property(node, "modulate:a", 0.0, 0.3)

## === THEME SWITCHING ===

func set_theme(new_theme: Theme) -> void:
	current_theme = new_theme
	var theme_res = _load_theme(new_theme)
	if theme_res:
		get_tree().root.theme = theme_res
	theme_changed.emit(new_theme)

func _load_theme(theme: Theme) -> Resource:
	match theme:
		Theme.DARK:         return load("res://themes/pixelshift_dark.tres")
		Theme.LIGHT:        return load("res://themes/pixelshift_light.tres")
		Theme.HIGH_CONTRAST:return load("res://themes/pixelshift_high_contrast.tres")
	return null

func toggle_theme() -> void:
	set_theme(Theme.LIGHT if current_theme == Theme.DARK else Theme.DARK)

## === MODAL DIALOGS ===

func show_modal(title: String, body: String, choices: Array[String] = ["OK"]) -> void:
	if _modal_open:
		return
	_modal_open = true
	
	var modal = _build_modal(title, body, choices)
	get_tree().root.add_child(modal)

func _build_modal(title: String, body: String, choices: Array[String]) -> Control:
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	
	var vbox = VBoxContainer.new()
	var title_label = Label.new()
	title_label.text = title
	var body_label = Label.new()
	body_label.text = body
	vbox.add_child(title_label)
	vbox.add_child(body_label)
	
	for choice in choices:
		var btn = Button.new()
		btn.text = choice
		btn.pressed.connect(func():
			modal_closed.emit(choice)
			overlay.queue_free()
			_modal_open = false
		)
		vbox.add_child(btn)
	
	panel.add_child(vbox)
	overlay.add_child(panel)
	return overlay
