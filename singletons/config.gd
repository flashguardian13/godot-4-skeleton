extends Node

# This is where all of the user's personal game settings are stored and
# persisted between gameplays. This is not for settings related to a particular
# instance of gameplay; rather, it is for general game behavior such as sound
# and music volume, graphical settings, language preferences, and the like.
#
# Values are stored in a JSON-style data structure consisting of nested
# Dictionaries. This is done to keep disk usage to a minimum and keep the key/
# value pairs organized. For convenience, access to these values from the app is
# done by passing a configuration key to the `get_value` and `set_value`
# functions. Such keys are a sequence of words separated by periods. See
# `valid_keys` for examples.

# The path where game configurations will be stored.
# Ref: https://docs.godotengine.org/en/stable/tutorials/io/data_paths.html
const CONFIG_PATH:String = "user://config.json"

# Configuration data will live in this variable during play.
var _values

# A list of valid configuration data keys. Other keys will be rejected with an
# error.
var valid_keys:Array = [
	"volume.Master",
	"volume.Music",
	"volume.Sound"
]

func _ready():
	if FileAccess.file_exists(CONFIG_PATH):
		# Load existing configuration from file
		var file:FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		_values = JSON.parse_string(file.get_as_text())
	else:
		# Start with an empty config and rely on defaults
		_values = {}
	# Update audio bus volumes
	for bus_name in ["Master", "Music", "Sound"]:
		var linear_volume:float = get_value("volume.%s" % bus_name, 1.0)
		var bus_index:int = AudioServer.get_bus_index(bus_name)
		AudioServer.set_bus_volume_db(bus_index, linear_to_db(linear_volume))

# Saves existing configurations to file. At a minimum, this should be called
# just before program exit.
func save() -> void:
	var file:FileAccess = FileAccess.open(CONFIG_PATH, FileAccess.WRITE)
	assert(file != null, "[Config] error saving to config file: %s" % FileAccess.get_open_error())
	file.store_string(JSON.stringify(_values))

# Navigates the configuration data structure looking for a particular value and,
# if it exists, returns it, otherwise returns null. The data structure will be
# auto-populated with empty Dictionaries as needed.
func _dig(keys:Array, node):
	# No more keys? We have arrived at the sought value!
	if keys.size() <= 0:
		return node
	# Safety check: we have more keys, so we must keep digging. But we can only
	# dig through Dictionaries.
	if !(node is Dictionary):
		assert(false, "[Config] error digging: node is not a Dictionary: %s" % node)
	# No such key at this part of the data structure?
	if !node.has(keys[0]):
		if keys.size() == 1:
			# We won't be digging any deeper, so we can return null.
			return null
		else:
			# We must keep digging, so add a new Dictionary at the current key.
			node[keys[0]] = {}
	# Continue digging from whatever resides at the current key
	return _dig(keys.slice(1), node[keys[0]])

# Rejects invalid keys with an error.
func _validate_key(key:String):
	if !valid_keys.has(key):
		assert(false, "[Config] bad key: %s" % key)

# Given a configuration key, returns the value for that key, if set. If not set
# or set to null, the given default value is returned.
func get_value(key:String, default = null):
	print("[Config] Getting value '%s' ..." % key)
	_validate_key(key)
	var tokens:PackedStringArray = key.split(".")
	var value = _dig(tokens, _values)
	return default if value == null else value

# Given a configuration key and a value, sets the value for that key in our
# configuration.
func set_value(key:String, value) -> void:
	print("[Config] Setting value of '%s' to '%s' ..." % [key, value])
	_validate_key(key)
	var tokens:PackedStringArray = key.split(".")
	var parent = _dig(tokens.slice(0, -1), _values)
	parent[tokens[-1]] = value
