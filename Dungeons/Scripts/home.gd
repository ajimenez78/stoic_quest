extends Dungeon

# Reflexiones guiadas del diario estoico. Cada una cultiva una virtud cardinal.
const PROMPTS := [
	{
		"id": "premeditatio",
		"question": "¿Qué podría salir mal hoy? ¿Cómo te prepararías?",
		"description": "Premeditatio Malorum · Anticipa obstáculos para estar preparado",
		"virtue": "temperance",
	},
	{
		"id": "control",
		"question": "¿Qué estuvo bajo tu control hoy? ¿Qué no lo estuvo?",
		"description": "Dicotomía del Control · Distingue lo que puedes y no puedes controlar",
		"virtue": "wisdom",
	},
	{
		"id": "gratitude",
		"question": "¿Por qué tres cosas estás agradecido hoy?",
		"description": "Práctica de Gratitud · Reconoce las bendiciones presentes",
		"virtue": "justice",
	},
	{
		"id": "virtue",
		"question": "¿En qué momento actuaste según tus valores hoy? ¿Cuándo no lo hiciste?",
		"description": "Examen de Virtud · Reflexiona sobre tu carácter",
		"virtue": "courage",
	},
]

const VIRTUE_POINTS_PER_ENTRY := 8
const SAVED_MESSAGE := "Entrada guardada. Has ganado puntos de virtud."
const MONTH_NAMES := [
	"enero", "febrero", "marzo", "abril", "mayo", "junio",
	"julio", "agosto", "septiembre", "octubre", "noviembre", "diciembre",
]

const PROMPT_CARD_SCENE := preload("res://Dungeons/UI/prompt_card.tscn")
const ENTRY_CARD_SCENE := preload("res://Dungeons/UI/journal_entry_card.tscn")
const CREDITS_DIALOG_SCENE := preload("res://Dungeons/UI/credits_dialog.tscn")

@onready var entries_value_label: Label = %EntriesValueLabel
@onready var streak_value_label: Label = %StreakValueLabel
@onready var practices_value_label: Label = %PracticesValueLabel

@onready var new_entry_tab: Button = %NewEntryTab
@onready var history_tab: Button = %HistoryTab

@onready var new_entry_panel: Control = %NewEntry
@onready var prompt_grid: GridContainer = %PromptGrid
@onready var question_label: Label = %QuestionLabel
@onready var entry_text_edit: TextEdit = %EntryTextEdit
@onready var char_count_label: Label = %CharCountLabel
@onready var save_button: Button = %SaveButton
@onready var toast_label: Label = %ToastLabel

@onready var history_panel: Control = %History
@onready var history_list: VBoxContainer = %HistoryList
@onready var empty_history: Control = %EmptyHistory

@onready var font_decrease_button: Button = %FontDecreaseButton
@onready var font_increase_button: Button = %FontIncreaseButton
@onready var credits_button: Button = %CreditsButton
@onready var font_size_label: Label = %FontSizeLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var stats_container: BoxContainer = %Stats
@onready var layout: MarginContainer = %Layout

const FONT_SCALES: Array[float] = [0.85, 1.0, 1.2, 1.4, 1.6, 1.8, 2.0]
var _current_scale_index: int = 1
var _base_font_sizes: Dictionary = {}
var _is_text_editing: bool = false
var _last_kb_height: int = 0

var _progress: Dictionary
var _selected_prompt: Dictionary = PROMPTS[0]
var _prompt_group := ButtonGroup.new()
var _toast_tween: Tween
var _credits_dialog: CreditsDialog

func _ready() -> void:
	_init_font_scale_index()
	_progress = ProgressStore.register_visit()

	new_entry_tab.pressed.connect(_show_new_entry)
	history_tab.pressed.connect(_show_history)
	entry_text_edit.text_changed.connect(_update_writing_state)
	entry_text_edit.focus_entered.connect(_on_text_edit_focus_entered)
	entry_text_edit.focus_exited.connect(_on_text_edit_focus_exited)
	save_button.pressed.connect(_on_save_pressed)

	if font_decrease_button:
		font_decrease_button.pressed.connect(_on_font_decrease_pressed)
	if font_increase_button:
		font_increase_button.pressed.connect(_on_font_increase_pressed)
	if credits_button:
		credits_button.pressed.connect(_on_credits_pressed)

	if scroll_container:
		_configure_scroll_pass_through(scroll_container)


	_cache_base_font_sizes(self)

	toast_label.modulate.a = 0.0
	_build_prompt_cards()
	_restore_draft()
	_refresh_stats()
	_rebuild_history()
	_show_new_entry()

	_update_responsive_layout()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_apply_font_scale()

func _init_font_scale_index() -> void:
	var is_mobile_screen: bool = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or get_viewport_rect().size.x < 600
	if is_mobile_screen:
		_current_scale_index = 3
	else:
		_current_scale_index = 1

func _process(_delta: float) -> void:
	if _is_text_editing:
		_check_virtual_keyboard()

func _on_text_edit_focus_entered() -> void:
	_is_text_editing = true
	_check_virtual_keyboard()
	_scroll_to_editor()

func _on_text_edit_focus_exited() -> void:
	_is_text_editing = false
	_reset_keyboard_padding()

func _check_virtual_keyboard() -> void:
	if not DisplayServer.has_feature(DisplayServer.FEATURE_VIRTUAL_KEYBOARD):
		return
	var kb_height := DisplayServer.virtual_keyboard_get_height()
	if kb_height != _last_kb_height:
		_last_kb_height = kb_height
		if kb_height > 0:
			var window_size := DisplayServer.window_get_size()
			var scale_y: float = get_viewport_rect().size.y / float(max(1, window_size.y))
			var adjusted_kb_height := int(round(kb_height * scale_y))
			if layout:
				layout.add_theme_constant_override("margin_bottom", 24 + adjusted_kb_height)
			_scroll_to_editor()
		else:
			_reset_keyboard_padding()

func _reset_keyboard_padding() -> void:
	_last_kb_height = 0
	if layout:
		layout.add_theme_constant_override("margin_bottom", 24)

func _scroll_to_editor() -> void:
	if scroll_container and entry_text_edit:
		scroll_container.ensure_control_visible(entry_text_edit)

func _clean_stale_font_size_cache() -> void:
	for control in _base_font_sizes.keys():
		if not is_instance_valid(control):
			_base_font_sizes.erase(control)

func _cache_base_font_sizes(node: Node) -> void:
	_clean_stale_font_size_cache()
	for child in node.get_children():
		if child is Control and child != font_decrease_button and child != font_increase_button and child != credits_button:
			if not _base_font_sizes.has(child):
				if child is RichTextLabel:
					var rtl := child as RichTextLabel
					var normal_s := rtl.get_theme_font_size("normal_font_size")
					var bold_s := rtl.get_theme_font_size("bold_font_size")
					if normal_s <= 0:
						normal_s = 13
					if bold_s <= 0:
						bold_s = 13
					_base_font_sizes[child] = {"normal": normal_s, "bold": bold_s}
				else:
					var base_size := (child as Control).get_theme_font_size("font_size")
					if base_size > 0:
						_base_font_sizes[child] = base_size
		_cache_base_font_sizes(child)

func _on_credits_pressed() -> void:
	if not _credits_dialog or not is_instance_valid(_credits_dialog):
		_credits_dialog = CREDITS_DIALOG_SCENE.instantiate() as CreditsDialog
		$UI.add_child(_credits_dialog)
	_credits_dialog.set_font_scale(FONT_SCALES[_current_scale_index])
	_credits_dialog.open()

func _configure_scroll_pass_through(node: Node) -> void:
	if node is Control and not (node is TextEdit) and not (node is ScrollContainer):
		if node is BaseButton:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_configure_scroll_pass_through(child)

func _update_responsive_layout() -> void:
	var viewport_width := get_viewport_rect().size.x
	if prompt_grid:
		prompt_grid.columns = 1
	if stats_container:
		stats_container.vertical = (viewport_width < 600)

func _on_font_decrease_pressed() -> void:
	if _current_scale_index > 0:
		_current_scale_index -= 1
		_apply_font_scale()

func _on_font_increase_pressed() -> void:
	if _current_scale_index < FONT_SCALES.size() - 1:
		_current_scale_index += 1
		_apply_font_scale()

func _apply_font_scale() -> void:
	var scale_factor := FONT_SCALES[_current_scale_index]
	if font_decrease_button:
		font_decrease_button.disabled = _current_scale_index <= 0
	if font_increase_button:
		font_increase_button.disabled = _current_scale_index >= FONT_SCALES.size() - 1

	for control in _base_font_sizes.keys():
		if is_instance_valid(control):
			var val = _base_font_sizes[control]
			if val is Dictionary and control is RichTextLabel:
				var rtl := control as RichTextLabel
				var normal_scaled := int(round(float(val.get("normal", 13)) * scale_factor))
				var bold_scaled := int(round(float(val.get("bold", 13)) * scale_factor))
				rtl.add_theme_font_size_override("normal_font_size", normal_scaled)
				rtl.add_theme_font_size_override("bold_font_size", bold_scaled)
			elif val is int or val is float:
				var scaled_size := int(round(float(val) * scale_factor))
				(control as Control).add_theme_font_size_override("font_size", scaled_size)

	if prompt_grid:
		for card in prompt_grid.get_children():
			if card.has_method("update_adaptive_minimum_size"):
				card.update_adaptive_minimum_size(scale_factor)
			elif card is Control:
				(card as Control).custom_minimum_size.y = int(round(90 * scale_factor))

	if _credits_dialog and is_instance_valid(_credits_dialog):
		_credits_dialog.set_font_scale(scale_factor)

# Guarda la reflexión a medio escribir al salir del hogar.
func _exit_tree() -> void:
	ProgressStore.save_draft(_selected_prompt.get("id", ""), entry_text_edit.text)

# Crea una tarjeta por cada reflexión guiada; solo una puede estar elegida.
func _build_prompt_cards() -> void:
	for prompt: Dictionary in PROMPTS:
		var card: PromptCard = PROMPT_CARD_SCENE.instantiate()
		prompt_grid.add_child(card)
		card.setup(prompt)
		card.button_group = _prompt_group
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.pressed.connect(_on_prompt_pressed.bind(card))
		_cache_base_font_sizes(card)
		_configure_scroll_pass_through(card)
	call_deferred("_apply_font_scale")

# Recupera la reflexión y el texto que quedaron sin guardar.
func _restore_draft() -> void:
	var draft: Dictionary = _progress["draft"]
	_select_prompt(_prompt_index(str(draft.get("prompt_id", ""))))
	entry_text_edit.text = str(draft.get("content", ""))
	_update_writing_state()

func _on_prompt_pressed(card: PromptCard) -> void:
	_select_prompt(_prompt_index(str(card.prompt.get("id", ""))))

# Marca una reflexión como la elegida y la muestra sobre el área de escritura.
func _select_prompt(index: int) -> void:
	_selected_prompt = PROMPTS[index]
	question_label.text = _selected_prompt["question"]
	var card := prompt_grid.get_child(index) as Button
	card.button_pressed = true

func _prompt_index(prompt_id: String) -> int:
	for index: int in PROMPTS.size():
		if PROMPTS[index]["id"] == prompt_id:
			return index
	return 0

# Actualiza el contador de caracteres y habilita el guardado.
func _update_writing_state() -> void:
	var text := entry_text_edit.text
	char_count_label.text = "%d caracteres" % text.length()
	save_button.disabled = text.strip_edges().is_empty()

func _on_save_pressed() -> void:
	var content := entry_text_edit.text.strip_edges()
	if content.is_empty():
		return

	_progress = ProgressStore.add_journal_entry(
		_selected_prompt["question"],
		content,
		_selected_prompt["virtue"],
		VIRTUE_POINTS_PER_ENTRY,
	)
	entry_text_edit.text = ""
	entry_text_edit.release_focus()
	_reset_keyboard_padding()
	if scroll_container:
		scroll_container.scroll_vertical = 0
	ProgressStore.save_draft("", "")

	_update_writing_state()
	_refresh_stats()
	_rebuild_history()
	_show_toast(SAVED_MESSAGE)

func _refresh_stats() -> void:
	entries_value_label.text = str((_progress["journal_entries"] as Array).size())
	streak_value_label.text = str(int(_progress["current_streak"]))
	practices_value_label.text = str((_progress["completed_practices"] as Array).size())

# Rehace la lista del historial con las entradas guardadas, la más reciente
# primero.
func _rebuild_history() -> void:
	for child in history_list.get_children():
		history_list.remove_child(child)
		child.queue_free()

	var entries: Array = _progress["journal_entries"]
	empty_history.visible = entries.is_empty()

	for entry in entries:
		if not (entry is Dictionary):
			continue
		var card: JournalEntryCard = ENTRY_CARD_SCENE.instantiate()
		history_list.add_child(card)
		card.setup(
			str(entry.get("prompt", "")),
			_format_date(str(entry.get("date", ""))),
			str(entry.get("content", "")),
		)
		_cache_base_font_sizes(card)
		_configure_scroll_pass_through(card)
	_apply_font_scale()

func _show_new_entry() -> void:
	new_entry_tab.button_pressed = true
	new_entry_panel.visible = true
	history_panel.visible = false

func _show_history() -> void:
	history_tab.button_pressed = true
	new_entry_panel.visible = false
	history_panel.visible = true

# Muestra un aviso que se desvanece tras unos segundos.
func _show_toast(message: String) -> void:
	toast_label.text = message
	toast_label.modulate.a = 1.0

	if _toast_tween and _toast_tween.is_valid():
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(2.5)
	_toast_tween.tween_property(toast_label, "modulate:a", 0.0, 0.6)

# Convierte una fecha ISO en el formato "28 de julio de 2026, 18:04".
func _format_date(iso_date: String) -> String:
	var date := Time.get_datetime_dict_from_datetime_string(iso_date, false)
	if date.is_empty():
		return iso_date

	return "%d de %s de %d, %02d:%02d" % [
		date["day"], MONTH_NAMES[int(date["month"]) - 1], date["year"],
		date["hour"], date["minute"],
	]
