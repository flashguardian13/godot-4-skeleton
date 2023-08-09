extends Node

const SAVE_FOLDER:String = "user://saves/"
const SAVE_EXTENSION:String = ".save"

func _ensure_save_folder() -> void:
	if !DirAccess.dir_exists_absolute(SAVE_FOLDER):
		DirAccess.make_dir_absolute(SAVE_FOLDER)

func get_save_names() -> Array:
	_ensure_save_folder()
	var saves:Array = []
	var dir:DirAccess = DirAccess.open(SAVE_FOLDER)
	for filename in dir.get_files():
		saves.push_back(path_to_name(filename))
	return saves

func path_to_name(path:String) -> String:
	return path.split("/")[-1].split(".")[0].replace("_", " ")

func name_to_path(name:String) -> String:
	return "".join([SAVE_FOLDER, name.validate_filename().replace(" ", "_"), SAVE_EXTENSION])

func validate_save_path(path:String) -> bool:
	if !path.begins_with(SAVE_FOLDER):
		return false
	if !path.ends_with(SAVE_EXTENSION):
		return false
	return true

func save_by_name(name:String) -> void:
	save_to_file(name_to_path(name))

func save_to_file(path:String) -> void:
	_ensure_save_folder()
	assert(validate_save_path(path), "Save path '%s' is invalid!" % path)
	var file:FileAccess = FileAccess.open(path, FileAccess.WRITE)
	assert(file != null, "save_to_file error: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(GameState.to_json()))

func load_by_name(name:String) -> void:
	load_from_file(name_to_path(name))

func load_from_file(path:String) -> void:
	_ensure_save_folder()
	assert(validate_save_path(path), "Save path '%s' is invalid!" % path)
	assert(FileAccess.file_exists(path), "File '%s' does not exist!" % path)
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	GameState.from_json(JSON.parse_string(file.get_as_text()))
