extends Node

func get_player() -> Node2D:
	return get_tree().get_nodes_in_group("music_player")[0]
