class_name SaveGameManager
extends Node

const SAVE_VERSION:int = 1

const SAVE_TEMPLATE = "user://save_slot_%d.json"

func _ready() -> void:
	pass

func _vec2_to_dict(v: Vector2) -> Dictionary:
	return {"x": v.x, "y": v.y}

func _dict_to_vec2(d: Dictionary) -> Vector2:
	return Vector2(d.get("x", 0.0), d.get("y", 0.0))

func _write_json(path: String, data: Dictionary) -> bool:
	var text = JSON.stringify(data)
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: %s" % path)
		return false
	file.store_string(text)
	file.close()
	return true

func _read_json(path: String) -> Dictionary:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed.error != OK:
		push_error("Failed to parse save JSON: %s" % parsed.error_string)
		return {}
	return parsed.result

func _gather_state() -> Dictionary:
	var game = GameManager
	var player = PlayerStateManager
	var time = TimeStateManager

	var state:Dictionary = {
		"meta": {
			"version": SAVE_VERSION,
			"saved_at": Time.get_time_dict_from_system()
		},

		"game": {
			"current_world": game.current_world,
			"current_level": game.current_level,
			"latest_checkpoint": _vec2_to_dict(game.latest_checkpoint),
			"max_remaining_time": game.max_remaining_time,
			"remaining_time": game.remaining_time,
			"max_run_remaining_time": game.max_run_remaining_time,
			"run_remaining_time": game.run_remaining_time,
			"is_in_resting_area": game.is_in_resting_area,
			"has_crossed_finish_line": game.has_crossed_finish_line,
			"is_in_shop": game.is_in_shop,
			"has_lost": game.has_lost,
			"completed_levels": game.completed_levels.duplicate(),
			"score_multiplicator": game.score_multiplicator,
			"upgrade_cost": game.upgrade_cost.duplicate(),
			"shop_odds": game.shop_odds,
			"speed_upgrade_costs_index": game.speed_upgrade_costs_index,
			"dash_upgrade_costs_index": game.dash_upgrade_costs_index,
			"bonus_time_upgrade_costs_index": game.bonus_time_upgrade_costs_index,
			"shop_items_upgrade_costs_index": game.shop_items_upgrade_costs_index,
			"damage": game.damage,
			"first_loss_flag": game.first_loss_flag,
			"first_win_flag": game.first_win_flag,
			"speed_maxed_flag": game.speed_maxed_flag,
			"dash_maxed_flag": game.dash_maxed_flag,
			"bonus_time_maxed_flag": game.bonus_time_maxed_flag,
			"shop_items_maxed_flag": game.shop_items_maxed_flag,
			"price_multiplicator": game.price_multiplicator,
			"cheat_death": game.cheat_death
		},

		"player": {
			"has_unlocked_dash": player.has_unlocked_dash,
			"is_in_cutscene": player.is_in_cutscene,
			"seconds_currency": player.seconds_currency,
			"player_speed_multiplicator": player.player_speed_multiplicator,
			"player_position": _vec2_to_dict(player.player_position),
			"is_facing_right": player.is_facing_right,
			"dash_cooldown": player.dash_cooldown,
			"can_dash": player.can_dash,
			"bonus_time": player.bonus_time,
			"number_of_shop_items": player.number_of_shop_items,
			"currently_hovered_shop_item": player.currently_hovered_shop_item
		},

		"time": {
			"introduction_flag": time.introduction_flag,
			"introduction_to_bonus_flag": time.introduction_to_bonus_flag
		}
	}

	return state

func _apply_state(state: Dictionary) -> void:
	if not state:
		push_error("apply_state received empty state")
		return
	var game = GameManager
	var player = PlayerStateManager
	var time = TimeStateManager

	var g = state.get("game", {})
	if g:
		game.current_world = int(g.get("current_world", game.current_world))
		game.current_level = int(g.get("current_level", game.current_level))
		if g.has("latest_checkpoint"):
			game.latest_checkpoint = _dict_to_vec2(g["latest_checkpoint"])
		game.max_remaining_time = float(g.get("max_remaining_time", game.max_remaining_time))
		game.remaining_time = float(g.get("remaining_time", game.remaining_time))
		game.max_run_remaining_time = float(g.get("max_run_remaining_time", game.max_run_remaining_time))
		game.run_remaining_time = float(g.get("run_remaining_time", game.run_remaining_time))
		game.is_in_resting_area = bool(g.get("is_in_resting_area", game.is_in_resting_area))
		game.has_crossed_finish_line = bool(g.get("has_crossed_finish_line", game.has_crossed_finish_line))
		game.is_in_shop = bool(g.get("is_in_shop", game.is_in_shop))
		game.has_lost = bool(g.get("has_lost", game.has_lost))
		# completed_levels might be an Array of ints
		var comp = g.get("completed_levels", null)
		if comp != null:
			game.completed_levels = comp.duplicate()
		game.score_multiplicator = float(g.get("score_multiplicator", game.score_multiplicator))
		# upgrade_cost stored as a dictionary of ints
		var up = g.get("upgrade_cost", null)
		if up != null:
			# keep only keys that exist to preserve any defaults
			for k in up.keys():
				game.upgrade_cost[k] = up[k]
		game.shop_odds = int(g.get("shop_odds", game.shop_odds))
		game.speed_upgrade_costs_index = int(g.get("speed_upgrade_costs_index", game.speed_upgrade_costs_index))
		game.dash_upgrade_costs_index = int(g.get("dash_upgrade_costs_index", game.dash_upgrade_costs_index))
		game.bonus_time_upgrade_costs_index = int(g.get("bonus_time_upgrade_costs_index", game.bonus_time_upgrade_costs_index))
		game.damage = int(g.get("damage", game.damage))
		game.first_loss_flag = bool(g.get("first_loss_flag", game.first_loss_flag))
		game.first_win_flag = bool(g.get("first_win_flag", game.first_win_flag))
		game.speed_maxed_flag = bool(g.get("speed_maxed_flag", game.speed_maxed_flag))
		game.dash_maxed_flag = bool(g.get("dash_maxed_flag", game.dash_maxed_flag))
		game.bonus_time_maxed_flag = bool(g.get("bonus_time_maxed_flag", game.bonus_time_maxed_flag))

		# Recompute upgrade_cost keys if indices changed (safety)
		if game.speed_upgrade_costs_index >= 0 and game.speed_upgrade_costs_index < len(game.speed_upgrade_costs):
			game.upgrade_cost["speed_cost"] = game.speed_upgrade_costs[game.speed_upgrade_costs_index]
		else:
			# clamp & mark maxed if needed
			if game.speed_upgrade_costs_index >= len(game.speed_upgrade_costs):
				game.speed_maxed_flag = true
				game.upgrade_cost["speed_cost"] = game.speed_upgrade_costs[-1]
		if game.dash_upgrade_costs_index >= 0 and game.dash_upgrade_costs_index < len(game.dash_upgrade_costs):
			game.upgrade_cost["dash_cooldown_cost"] = game.dash_upgrade_costs[game.dash_upgrade_costs_index]
		else:
			if game.dash_upgrade_costs_index >= len(game.dash_upgrade_costs):
				game.dash_maxed_flag = true
				game.upgrade_cost["dash_cooldown_cost"] = game.dash_upgrade_costs[-1]
		if game.bonus_time_upgrade_costs_index >= 0 and game.bonus_time_upgrade_costs_index < len(game.bonus_time_upgrade_costs):
			game.upgrade_cost["bonus_time_cost"] = game.bonus_time_upgrade_costs[game.bonus_time_upgrade_costs_index]
		else:
			if game.bonus_time_upgrade_costs_index >= len(game.bonus_time_upgrade_costs):
				game.bonus_time_maxed_flag = true
				game.upgrade_cost["bonus_time_cost"] = game.bonus_time_upgrade_costs[-1]

	# --- PLAYER ---
	var p = state.get("player", {})
	if p:
		player.has_unlocked_dash = bool(p.get("has_unlocked_dash", player.has_unlocked_dash))
		player.is_in_cutscene = bool(p.get("is_in_cutscene", player.is_in_cutscene))
		player.seconds_currency = float(p.get("seconds_currency", player.seconds_currency))
		player.player_speed_multiplicator = float(p.get("player_speed_multiplicator", player.player_speed_multiplicator))
		if p.has("player_position"):
			player.player_position = _dict_to_vec2(p["player_position"])
		player.is_facing_right = bool(p.get("is_facing_right", player.is_facing_right))
		player.dash_cooldown = float(p.get("dash_cooldown", player.dash_cooldown))
		player.can_dash = bool(p.get("can_dash", player.can_dash))
		player.bonus_time = int(p.get("bonus_time", player.bonus_time))

	# --- TIME (NPC) ---
	var t = state.get("time", {})
	if t:
		time.introduction_flag = bool(t.get("introduction_flag", time.introduction_flag))
		time.introduction_to_bonus_flag = bool(t.get("introduction_to_bonus_flag", time.introduction_to_bonus_flag))

# ----------------------
# public API
# ----------------------
func save_game(slot: int = 0) -> bool:
	var path = SAVE_TEMPLATE % slot
	var state = _gather_state()
	return _write_json(path, state)

func load_game(slot: int = 0) -> bool:
	var path = SAVE_TEMPLATE % slot
	var data = _read_json(path)
	if data.empty():
		return false
	# optional: check version and migrate if needed
	var meta = data.get("meta", {})
	var version = int(meta.get("version", 0))
	if version != SAVE_VERSION:
		# implement migration logic here if you change the format later
		# for now, we assume same version
		push_warning("Save version mismatch: %d (expected %d). Attempting to load anyway." %
					 [version, SAVE_VERSION])
	_apply_state(data)
	return true

func quick_save() -> bool:
	return save_game(0)

func quick_load() -> bool:
	return load_game(0)

func delete_save(slot: int = 0) -> bool:
	var path = SAVE_TEMPLATE % slot
	if not FileAccess.file_exists(path):
		return false
	var err = DirAccess.remove_absolute(path)
	return err == OK

func has_save(slot: int = 0) -> bool:
	var path = SAVE_TEMPLATE % slot
	return FileAccess.file_exists(path)
