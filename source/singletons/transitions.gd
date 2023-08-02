extends Node

var _scene_cache:Dictionary = {}

var _busy:bool = false
var is_busy:bool :
	get:
		return _busy

func _main() -> Node2D:
	return get_tree().get_nodes_in_group("main")[0]

func _load_scene_cached(scene_path:String):
	if !_scene_cache.has(scene_path):
		_scene_cache[scene_path] = ResourceLoader.load(scene_path)
	return _scene_cache[scene_path]

func start_transition(transition_path:String, scene_path:String):
	if _busy:
		return
	
	_busy = true
	var transition = _load_scene_cached(transition_path).instantiate()
	_main().get_node("Transition").add_child(transition)
	transition.screen_obscured.connect(_on_screen_obscured.bind(scene_path))
	transition.transition_complete.connect(_on_transition_complete)

func _on_screen_obscured(scene_path:String):
	var stage:MarginContainer = _main().get_node("Stage")
	for child in stage.get_children():
		stage.remove_child(child)
		child.queue_free()
		
	var scene = _load_scene_cached(scene_path).instantiate()
	stage.add_child(scene)

func _on_transition_complete():
	var transition:MarginContainer = _main().get_node("Transition")
	for child in transition.get_children():
		transition.remove_child(child)
		child.queue_free()
	_busy = false
