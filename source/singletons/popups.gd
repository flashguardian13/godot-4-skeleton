extends Node

func _get_main() -> Node:
	return get_tree().get_first_node_in_group("main")

func confirm_action(title:String, body:String) -> bool:
	var cd:ConfirmationDialog = _get_main().get_node("Popups/ConfirmAction")
	cd.title = title
	cd.dialog_text = body
	cd.popup_centered()
	return await cd.resolved

func save_first() -> String:
	var cd:AcceptDialog = _get_main().get_node("Popups/SaveFirst")
	cd.popup_centered()
	return await cd.verdict

func select_save(mode:String) -> Dictionary:
	var cd:Window = _get_main().get_node("Popups/SaveSelect")
	cd.set_select_mode(mode)
	cd.popup_centered()
	return await cd.resolved

func save_as() -> Dictionary:
	var cd:ConfirmationDialog = _get_main().get_node("Popups/SaveAs")
	cd.popup_centered()
	return await cd.resolved
