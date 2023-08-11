extends Node

func save_first() -> String:
	var main = get_tree().get_first_node_in_group("main")
	var cd:AcceptDialog = main.get_node("Popups/SaveFirst")
	cd.popup_centered()
	return await cd.verdict
