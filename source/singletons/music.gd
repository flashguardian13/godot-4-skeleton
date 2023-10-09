extends Node

# A singleton providing global access to the music player, wherever it might be
# in the scene tree.

func get_player() -> Node2D:
	return get_tree().get_nodes_in_group("music_player")[0]
