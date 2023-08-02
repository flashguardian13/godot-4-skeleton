extends MarginContainer

signal screen_obscured
signal transition_complete

func _ready():
	$ColorRect/AnimationPlayer.play("fade_to_black")

func _on_animation_player_animation_finished(_anim_name):
	if $ColorRect.color.a >= 1:
		emit_signal("screen_obscured")
		$ColorRect/AnimationPlayer.play_backwards("fade_to_black")
	else:
		emit_signal("transition_complete")
