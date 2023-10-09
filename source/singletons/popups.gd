extends Node

# This singleton can display the various popups of the game. Popups should be
# added to the Main scene under the "Popups" node so that they display over any
# other game screens and transitions and the like.

# Convenience method for getting the Main node. The Main node is the sole member
# of group "main", making it easy to discover.
func _get_main() -> Node:
	return get_tree().get_first_node_in_group("main")

# Displays a confirmation popup, asking the user to say yes/okay or no/cancel to
# a given proposition.
func confirm_action(title:String, body:String) -> bool:
	var cd:ConfirmationDialog = _get_main().get_node("Popups/ConfirmAction")
	cd.title = title
	cd.dialog_text = body
	cd.popup_centered()
	return await cd.resolved

# Displays a popup explaining to the user that the action they've requested will
# discard the current game state and then asking if they would like to save
# before that action is resolved.
func save_first() -> String:
	var cd:AcceptDialog = _get_main().get_node("Popups/SaveFirst")
	cd.popup_centered()
	return await cd.verdict

# Displays the saved game selection popup, allowing the user to choose one of
# any saved games on disk or, when saving the game, save to a new file.
func select_save(mode:String) -> Dictionary:
	var cd:Window = _get_main().get_node("Popups/SaveSelect")
	cd.set_select_mode(mode)
	cd.popup_centered()
	return await cd.resolved

# Asks the user for a name by which to save the current game.
func save_as() -> Dictionary:
	var cd:ConfirmationDialog = _get_main().get_node("Popups/SaveAs")
	cd.popup_centered()
	return await cd.resolved

# Displays the settings popup.
func settings() -> void:
	var settings:Window = _get_main().get_node("Popups/Settings")
	settings.popup_centered()
