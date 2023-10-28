extends Node

# Saved games manager. Handles all disk I/O for reading and writing game states
# to and from the disk.
#
# Wherever possible, outside of this singleton, saved games are referred to by
# their name instead of a filename or path. Names are a sanitized derivation of
# the save file's name minus its extension. Save file paths are likewise
# sanitized, so names and paths may not map one-to-one when special characters
# are involved.

# Here is where the saved data will be stored.
# Ref: https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
const SAVE_FOLDER:String = "user://saves/"

# The extension applied to all save files.
const SAVE_EXTENSION:String = ".save"

# Creates the saved games directory if it does not exist.
func _ensure_save_folder() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_FOLDER):
		DirAccess.make_dir_absolute(SAVE_FOLDER)

# Returns a list of the names of all game states saved to disk.
func get_save_names() -> Array:
	_ensure_save_folder()
	var saves:Array = []
	var dir:DirAccess = DirAccess.open(SAVE_FOLDER)
	for filename in dir.get_files():
		saves.push_back(path_to_name(filename))
	return saves

# Returns true if a saved game exists with the given name.
func has_game_name(name:String) -> bool:
	var canonical_name:String = path_to_name(name_to_path(name))
	return get_save_names().has(canonical_name)

# Translates a file path to a saved game name.
func path_to_name(path:String) -> String:
	return path.split("/")[-1].split(".")[0].replace("_", " ")

# Translates a saved game name to a file path.
func name_to_path(name:String) -> String:
	return "".join([SAVE_FOLDER, name.validate_filename().replace(" ", "_"), SAVE_EXTENSION])

# Returns true if this String looks like a valid saved game path, false
# otherwise.
func validate_save_path(path:String) -> bool:
	if !path.begins_with(SAVE_FOLDER):
		return false
	if !path.ends_with(SAVE_EXTENSION):
		return false
	return true

# Returns a summary of information about the saved game with the given name.
# Among other things, this serves as preview information for the saved games
# displayed on the save select popup.
func get_save_info(name:String) -> Dictionary:
	_ensure_save_folder()
	var path:String = name_to_path(name)
	assert(validate_save_path(path), "Save path '%s' is invalid!" % path)
	assert(FileAccess.file_exists(path), "File '%s' does not exist!" % path)
	var t:Dictionary = Time.get_datetime_dict_from_unix_time(FileAccess.get_modified_time(path))
	var t_str:String = "%d-%d-%d, %d:%02d:%02d" % [t["year"], t["month"], t["day"], t["hour"], t["minute"], t["second"]]
	return { "name": name, "date": t_str }

# Saves the current game's state to the file associated with the given save
# name.
func save_by_name(name:String) -> void:
	save_to_file(name_to_path(name))

# Saves the current game's state to the given file (in JSON format).
func save_to_file(path:String) -> void:
	_ensure_save_folder()
	assert(validate_save_path(path), "Save path '%s' is invalid!" % path)
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null, "save_to_file error: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(GameState.to_json()))

# Loads a saved game state by its name and replaces the current game state with
# it.
func load_by_name(name:String) -> void:
	load_from_file(name_to_path(name))

# Loads a saved game state at the given path and replaces the current game state
# with it.
func load_from_file(path:String) -> void:
	_ensure_save_folder()
	assert(validate_save_path(path), "Save path '%s' is invalid!" % path)
	assert(FileAccess.file_exists(path), "File '%s' does not exist!" % path)
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	GameState.from_json(JSON.parse_string(file.get_as_text()))
