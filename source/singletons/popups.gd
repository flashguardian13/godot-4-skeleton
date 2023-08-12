extends Node

func _get_main() -> Node:
	return get_tree().get_first_node_in_group("main")

func save_first() -> String:
	var cd:AcceptDialog = _get_main().get_node("Popups/SaveFirst")
	cd.popup_centered()
	return await cd.verdict

func select_save() -> Dictionary:
	var cd:Window = _get_main().get_node("Popups/SaveSelect")
	cd.popup_centered()
	return await cd.resolved
