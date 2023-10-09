extends MarginContainer

# A simple screen transition that fades from the current screen to all black,
# then from black to the new screen.

signal screen_obscured
signal transition_complete

func _ready():
	# Start fading out as soon as we are added to the scene tree
	$ColorRect/AnimationPlayer.play("fade_to_black")

func _on_animation_player_animation_finished(_anim_name):
	# If we have fully faded to black, let the transitions manager know that
	# it's time to switch to the new screen, then start fading in.
	if $ColorRect.color.a >= 1:
		emit_signal("screen_obscured")
		$ColorRect/AnimationPlayer.play_backwards("fade_to_black")
	# Otherwise, let the transitions manager know that we have finished our
	# fade-in.
	else:
		emit_signal("transition_complete")
