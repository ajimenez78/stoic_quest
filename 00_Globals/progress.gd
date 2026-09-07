# Almacén del progreso del aprendiz: entradas del diario estoico, puntos de
# virtud, prácticas del gimnasio, retos semanales, racha de visitas y el
# borrador de la entrada en curso.
# Se persiste como JSON en user:// para que funcione en Android, iOS y web.
class_name ProgressStore extends RefCounted

const SAVE_PATH := "user://progress.json"
const MAX_VIRTUE_POINTS := 100
const DEFAULT_VIRTUES := {
	"wisdom": 0,
	"justice": 0,
	"courage": 0,
	"temperance": 0,
}

# Puntos de virtud (sumando las cuatro) necesarios para subir de nivel.
const POINTS_PER_LEVEL := 30

# Devuelve el progreso guardado, completado con los valores por omisión.
static func load_progress() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return _default_progress()

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("No se pudo leer el progreso: %s" % SAVE_PATH)
		return _default_progress()

	var content := file.get_as_text()
	file.close()

	var data: Variant = JSON.parse_string(content)
	if not (data is Dictionary):
		push_error("El progreso guardado está mal formado: %s" % SAVE_PATH)
		return _default_progress()

	return _merge_defaults(data)

# Escribe el progreso completo en disco.
static func save_progress(progress: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo guardar el progreso: %s" % SAVE_PATH)
		return

	file.store_string(JSON.stringify(progress, "\t"))
	file.close()

# Añade una entrada al diario (la más reciente primero) y suma los puntos de
# virtud correspondientes. Devuelve el progreso resultante.
static func add_journal_entry(prompt: String, content: String, virtue: String, points: int) -> Dictionary:
	var progress := load_progress()

	var entries: Array = progress["journal_entries"]
	entries.insert(0, {
		"date": Time.get_datetime_string_from_system(),
		"prompt": prompt,
		"content": content,
		"virtue": virtue,
	})

	_add_virtue_points(progress, virtue, points)

	save_progress(progress)
	return progress

# Marca una práctica diaria del gimnasio como hecha hoy y suma sus puntos de
# virtud. Una misma práctica solo puntúa una vez al día.
static func complete_practice(practice_id: String, virtue: String, points: int) -> Dictionary:
	var progress := load_progress()
	if is_practice_done_today(progress, practice_id):
		return progress

	var practices: Array = progress["completed_practices"]
	practices.insert(0, {
		"id": practice_id,
		"date": Time.get_date_string_from_system(),
		"virtue": virtue,
	})
	_add_virtue_points(progress, virtue, points)

	save_progress(progress)
	return progress

# ¿Se ha hecho ya hoy esta práctica diaria?
static func is_practice_done_today(progress: Dictionary, practice_id: String) -> bool:
	var today := Time.get_date_string_from_system()
	for practice: Variant in progress["completed_practices"]:
		if not (practice is Dictionary):
			continue
		if str(practice.get("id", "")) == practice_id and str(practice.get("date", "")) == today:
			return true
	return false

# Anota una partida de un mini-juego. Los puntos solo se entregan la primera vez
# de cada día, para que rejugarlo sea práctica y no una forma de acumular.
static func register_minigame_result(minigame_id: String, rewards: Dictionary) -> Dictionary:
	var progress := load_progress()
	var today := Time.get_date_string_from_system()
	var minigames: Dictionary = progress["minigames"]
	var state: Dictionary = minigames.get(minigame_id, {})

	if str(state.get("last_reward", "")) != today:
		for virtue: String in rewards:
			_add_virtue_points(progress, virtue, int(rewards[virtue]))
		state["last_reward"] = today

	state["plays"] = int(state.get("plays", 0)) + 1
	minigames[minigame_id] = state

	save_progress(progress)
	return progress

# ¿Ha puntuado ya hoy este mini-juego?
static func is_minigame_rewarded_today(progress: Dictionary, minigame_id: String) -> bool:
	var minigames: Dictionary = progress["minigames"]
	if not (minigames.get(minigame_id) is Dictionary):
		return false
	return str(minigames[minigame_id].get("last_reward", "")) == Time.get_date_string_from_system()

# Apunta el día de hoy en un reto semanal. Al alcanzar los días exigidos, el
# reto queda completado y entrega su recompensa una única vez por semana.
static func register_challenge_day(challenge: Dictionary) -> Dictionary:
	var progress := load_progress()
	var challenge_id := str(challenge["id"])
	var state := challenge_state(progress, challenge_id)
	var today := Time.get_date_string_from_system()

	if state["done_today"]:
		return progress

	var days: Array = state["days"]
	days.append(today)

	var completed: bool = days.size() >= int(challenge["target_days"])
	if completed and not state["rewarded"]:
		_add_virtue_points(progress, str(challenge["virtue"]), int(challenge["points"]))

	var challenges: Dictionary = progress["weekly_challenges"]
	challenges[challenge_id] = {
		"week": current_week_start(),
		"days": days,
		"rewarded": completed or state["rewarded"],
	}

	save_progress(progress)
	return progress

# Estado de un reto en la semana en curso: días ya apuntados, si hoy está
# apuntado y si la recompensa ya se entregó. El progreso de semanas anteriores
# se descarta, porque cada semana el reto empieza de cero.
static func challenge_state(progress: Dictionary, challenge_id: String) -> Dictionary:
	var empty := {"days": [], "done_today": false, "rewarded": false}

	var challenges: Dictionary = progress["weekly_challenges"]
	if not (challenges.get(challenge_id) is Dictionary):
		return empty

	var state: Dictionary = challenges[challenge_id]
	if str(state.get("week", "")) != current_week_start():
		return empty

	var days: Array = state["days"] if state.get("days") is Array else []
	return {
		"days": days,
		"done_today": days.has(Time.get_date_string_from_system()),
		"rewarded": bool(state.get("rewarded", false)),
	}

# Nivel del aprendiz, según el total de puntos de virtud acumulados.
static func level(progress: Dictionary) -> int:
	return int(float(total_virtue_points(progress)) / POINTS_PER_LEVEL) + 1

# Puntos que faltan para alcanzar el nivel siguiente.
static func points_to_next_level(progress: Dictionary) -> int:
	return POINTS_PER_LEVEL - total_virtue_points(progress) % POINTS_PER_LEVEL

static func total_virtue_points(progress: Dictionary) -> int:
	var total := 0
	for points: Variant in (progress["virtues"] as Dictionary).values():
		total += int(points)
	return total

# Virtud con menos puntos, la que el mentor sugiere cultivar para que el
# desarrollo del carácter se mantenga equilibrado.
static func weakest_virtue(progress: Dictionary) -> String:
	var virtues: Dictionary = progress["virtues"]
	var weakest := ""
	for virtue: String in virtues:
		if weakest.is_empty() or int(virtues[virtue]) < int(virtues[weakest]):
			weakest = virtue
	return weakest

# Lunes de la semana en curso, en formato "AAAA-MM-DD". Identifica la semana a
# la que pertenece el progreso de los retos.
static func current_week_start() -> String:
	# Time cuenta los días desde el domingo (0); la semana empieza en lunes.
	var days_since_monday := (int(Time.get_datetime_dict_from_system()["weekday"]) + 6) % 7
	var today := Time.get_unix_time_from_system()
	return Time.get_date_string_from_unix_time(int(today) - days_since_monday * 86400)

# Actualiza la racha de días consecutivos con visita al hogar.
static func register_visit() -> Dictionary:
	var progress := load_progress()
	var today := Time.get_date_string_from_system()
	var last_visit: String = progress["last_visit"]

	if last_visit == today:
		return progress

	if last_visit.is_empty():
		progress["current_streak"] = 1
	else:
		var days := _days_between(last_visit, today)
		if days == 1:
			progress["current_streak"] = int(progress["current_streak"]) + 1
		elif days > 1:
			progress["current_streak"] = 1

	progress["last_visit"] = today
	save_progress(progress)
	return progress

# Guarda la reflexión a medio escribir para recuperarla en la próxima visita.
static func save_draft(prompt_id: String, content: String) -> void:
	var progress := load_progress()
	progress["draft"] = {"prompt_id": prompt_id, "content": content}
	save_progress(progress)

# ¿Ha completado el aprendiz el tutorial inicial?
static func is_tutorial_completed(progress: Dictionary = {}) -> bool:
	if progress.is_empty():
		progress = load_progress()
	return bool(progress.get("tutorial_completed", false))

# Devuelve el paso actual del tutorial ("intro", "stoa", "gym", "home", "completed").
static func get_tutorial_step(progress: Dictionary = {}) -> String:
	if progress.is_empty():
		progress = load_progress()
	return str(progress.get("tutorial_step", "intro"))

# Avanza el tutorial al siguiente paso y persiste los cambios.
static func advance_tutorial_step(next_step: String) -> Dictionary:
	var progress := load_progress()
	progress["tutorial_step"] = next_step
	if next_step == "completed":
		progress["tutorial_completed"] = true
	save_progress(progress)
	return progress

# Marca el tutorial como completado y entrega la base de virtudes iniciales.
static func complete_tutorial() -> Dictionary:
	var progress := load_progress()
	progress["tutorial_step"] = "completed"
	progress["tutorial_completed"] = true
	for virtue: String in DEFAULT_VIRTUES.keys():
		if int(progress["virtues"].get(virtue, 0)) == 0:
			_add_virtue_points(progress, virtue, 5)
	save_progress(progress)
	return progress

# Suma puntos a una virtud sin pasar de su tope.
static func _add_virtue_points(progress: Dictionary, virtue: String, points: int) -> void:
	var virtues: Dictionary = progress["virtues"]
	if virtues.has(virtue):
		virtues[virtue] = mini(int(virtues[virtue]) + points, MAX_VIRTUE_POINTS)

static func _default_progress() -> Dictionary:
	return {
		"journal_entries": [],
		"virtues": DEFAULT_VIRTUES.duplicate(),
		"completed_practices": [],
		"weekly_challenges": {},
		"minigames": {},
		"current_streak": 0,
		"last_visit": "",
		"draft": {"prompt_id": "", "content": ""},
		"tutorial_step": "intro",
		"tutorial_completed": false,
	}

# Completa los datos leídos con las claves que falten, para que una partida
# antigua siga siendo válida al añadir campos nuevos.
static func _merge_defaults(data: Dictionary) -> Dictionary:
	var progress := _default_progress()
	progress.merge(data, true)

	var virtues: Dictionary = DEFAULT_VIRTUES.duplicate()
	if data.get("virtues") is Dictionary:
		virtues.merge(data["virtues"], true)
	progress["virtues"] = virtues

	if not (progress["journal_entries"] is Array):
		progress["journal_entries"] = []
	if not (progress["completed_practices"] is Array):
		progress["completed_practices"] = []
	if not (progress["weekly_challenges"] is Dictionary):
		progress["weekly_challenges"] = {}
	if not (progress["minigames"] is Dictionary):
		progress["minigames"] = {}
	if not (progress["draft"] is Dictionary):
		progress["draft"] = {"prompt_id": "", "content": ""}
	if not data.has("tutorial_step"):
		progress["tutorial_step"] = "intro"
	if not data.has("tutorial_completed"):
		progress["tutorial_completed"] = false

	return progress

# Días completos transcurridos entre dos fechas "AAAA-MM-DD".
static func _days_between(from_date: String, to_date: String) -> int:
	var from_seconds := Time.get_unix_time_from_datetime_string(from_date + "T00:00:00")
	var to_seconds := Time.get_unix_time_from_datetime_string(to_date + "T00:00:00")
	return int(floor((to_seconds - from_seconds) / 86400.0))
