extends Dungeon

const QUOTE_STRING_TEMPLATE =  "[font_size=18][i][color=black]%s[/color][/i][/font_size]"
const AUTHOR_STRING_TEMPLATE =  "[font_size=17][color=brown]- %s[/color][/font_size]"
const QUOTES_DATABASE_PATH = "res://Dungeons/quotes.json"

@onready var quote_rich_text_label: RichTextLabel = %QuoteRichTextLabel
@onready var author_rich_text_label: RichTextLabel = %AuthorRichTextLabel
@onready var previous_button: TextureButton = %PreviousButton
@onready var next_button: TextureButton = %NextButton
@onready var virtues_grid: GridContainer = %VirtuesGrid
@onready var font_decrease_button: Button = %FontDecreaseButton
@onready var font_increase_button: Button = %FontIncreaseButton
@onready var font_size_label: Label = %FontSizeLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer

const FONT_SCALES: Array[float] = [0.85, 1.0, 1.2, 1.4, 1.6, 1.8, 2]
var _current_scale_index: int = 1
var _original_texts: Dictionary = {}

# History of quotes shown, with a pointer to the currently displayed one.
var _history: Array[Dictionary] = []
var _current_index: int = -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_init_font_scale_index()
	next_button.pressed.connect(_on_next_pressed)
	previous_button.pressed.connect(_on_previous_pressed)
	if font_decrease_button:
		font_decrease_button.pressed.connect(_on_font_decrease_pressed)
	if font_increase_button:
		font_increase_button.pressed.connect(_on_font_increase_pressed)

	# Configure non-button control nodes to ignore touch events so drag gestures pass to ScrollContainer
	if scroll_container:
		_configure_scroll_pass_through(scroll_container)

	# Cache original BBCode texts for static labels
	for label in find_children("*", "RichTextLabel"):
		_original_texts[label] = label.text

	_update_responsive_layout()
	get_viewport().size_changed.connect(_update_responsive_layout)
	_apply_font_scale()
	_on_next_pressed()

func _init_font_scale_index() -> void:
	var is_mobile_screen: bool = OS.has_feature("mobile") or DisplayServer.is_touchscreen_available() or get_viewport_rect().size.x < 600
	if is_mobile_screen:
		_current_scale_index = 3
	else:
		_current_scale_index = 1

func _configure_scroll_pass_through(node: Node) -> void:
	if node is Control and not (node is ScrollContainer):
		if node is BaseButton:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_PASS
		else:
			(node as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_configure_scroll_pass_through(child)

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

	if font_size_label:
		font_size_label.add_theme_font_size_override("font_size", int(round(14 * scale_factor)))

	for label in _original_texts.keys():
		if is_instance_valid(label) and label != quote_rich_text_label and label != author_rich_text_label:
			label.text = _scale_bbcode(_original_texts[label], scale_factor)

	_display_current_quote()

func _scale_bbcode(text: String, scale_factor: float) -> String:
	if scale_factor == 1.0:
		return text
	var regex := RegEx.new()
	regex.compile("\\[font_size=(\\d+)\\]")
	var result := text
	var matches := regex.search_all(text)
	for i in range(matches.size() - 1, -1, -1):
		var m := matches[i]
		var orig_size := m.get_string(1).to_int()
		var new_size := int(round(orig_size * scale_factor))
		var start := m.get_start(1)
		var end := m.get_end(1)
		result = result.substr(0, start) + str(new_size) + result.substr(end)
	return result

func _update_responsive_layout() -> void:
	if virtues_grid:
		var vp_width := get_viewport().get_visible_rect().size.x
		if vp_width < 600:
			virtues_grid.columns = 1
		else:
			virtues_grid.columns = 2

# Shows the next quote: moves forward in history, or picks a new random one
# when already at the most recent entry.
func _on_next_pressed() -> void:
	if _current_index < _history.size() - 1:
		_current_index += 1
	else:
		_history.append(_pick_random_quote())
		_current_index = _history.size() - 1
	_display_current_quote()

# Shows the previous quote in history.
func _on_previous_pressed() -> void:
	if _current_index > 0:
		_current_index -= 1
		_display_current_quote()

# Renders the quote at the current history index and updates button state.
func _display_current_quote() -> void:
	var quote := _history[_current_index]
	var scale_factor := FONT_SCALES[_current_scale_index]
	var raw_quote := QUOTE_STRING_TEMPLATE % quote.get("quote", "")
	var raw_author := AUTHOR_STRING_TEMPLATE % quote.get("author", "")
	quote_rich_text_label.text = _scale_bbcode(raw_quote, scale_factor)
	author_rich_text_label.text = _scale_bbcode(raw_author, scale_factor)
	previous_button.disabled = _current_index <= 0

# Loads the quotes database and returns a random entry as a Dictionary.
func _pick_random_quote() -> Dictionary:
	var file := FileAccess.open(QUOTES_DATABASE_PATH, FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir la base de datos de frases: %s" % QUOTES_DATABASE_PATH)
		return {}

	var content := file.get_as_text()
	file.close()

	var quotes: Variant = JSON.parse_string(content)
	if not (quotes is Array) or quotes.is_empty():
		push_error("La base de datos de frases está vacía o mal formada: %s" % QUOTES_DATABASE_PATH)
		return {}

	return quotes.pick_random()
