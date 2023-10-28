extends Node

# Handles transitions from one game screen to another. This is achieved by
# adding a full-window transition Node to the scene tree in a way that will
# obscure the whole window. The transition should notify us when the window is
# fully obscured so that we know when to remove the old screen from the scene
# tree and replace it with the new screen.

# Screen transition resource paths
const TRANSITION_FADE_TO_BLACK:String = "res://scenes/transitions/fade_to_black.tscn"

# Screen resource paths
const SCREEN_SPLASH:String = "res://scenes/screens/splash.tscn"
const SCREEN_MAIN_MENU:String =     "res://scenes/screens/main_menu.tscn"
const SCREEN_TIC_TAC_TOE:String =   "res://scenes/screens/tic_tac_toe.tscn"

# Scenes only need to be loaded once before they can be instantiated, so we'll
# keep each scene definition in this cache here.
var _scene_cache:Dictionary = {}

# True if a transition is in progress, false otherwise.
var _busy:bool = false
var is_busy:bool :
	get:
		return _busy

# Convenience method for getting the Main node. The Main node is the sole member
# of group "main", making it easy to discover.
func _main() -> Node2D:
	return get_tree().get_nodes_in_group("main")[0]

# Returns resources from the cache, loading them into the cache as needed.
func _load_scene_cached(scene_path:String):
	if !_scene_cache.has(scene_path):
		_scene_cache[scene_path] = ResourceLoader.load(scene_path)
	return _scene_cache[scene_path]

# Starts a screen transition, using the given transition and changing to the
# given screen from the current one. Transitions are added to the "Transition"
# child of the Main node, where screens are added to the "Stage" child,
# effectively layering transitions over screens in the render order.
func start_transition(transition_path:String, scene_path:String):
	# Don't transition again if we're mid-transition. Callers need to do due
	# dilligence before calling for a screen transtion.
	if _busy:
		return
	print("Starting transition to: %s" % scene_path)
	_busy = true
	# Instantiate the desired transition animation and add it to the scene tree.
	var transition = _load_scene_cached(transition_path).instantiate()
	_main().get_node("Transition").add_child(transition)
	# Connect transition signals to our handler methods.
	transition.screen_obscured.connect(_on_screen_obscured.bind(scene_path))
	transition.transition_complete.connect(_on_transition_complete)

# Called when the transition says the window's contents are fully obscured and
# therefore the user won't notice if we swap screens.
func _on_screen_obscured(scene_path:String):
	# Remove the current screen instance from the scene tree.
	var stage:Node = _main().get_node("Stage")
	for child in stage.get_children():
		stage.remove_child(child)
		child.queue_free()
	# Add the desired screen instance to the scene tree.
	var scene = _load_scene_cached(scene_path).instantiate()
	stage.add_child(scene)

# Called when a screen transition's animation has completed, at which point it
# should be fully transparent and therefore ready to be removed.
func _on_transition_complete():
	# Remove the current transition instance from the scene tree.
	var transition:Node = _main().get_node("Transition")
	for child in transition.get_children():
		transition.remove_child(child)
		child.queue_free()
	print("Transition complete.")
	_busy = false
