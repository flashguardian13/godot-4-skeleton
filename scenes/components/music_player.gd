extends Node2D

# Originally, I set out to make the music player a singleton so that it can be
# easily dropped in or taken out, but it was more convenient to have
# MusicPlayers which are configurable via Godot's UI.

# This variable will hold the tween driving the current cross-fade, if any.
var _cross_fader:Tween = null

# If we try to transition to a new piece of music while a transition is already
# in progress, we will add the music to a queue and transition to it once all
# preceding transitions have completed.
var _cross_fade_queue:Array = []

# Tells the player to start cross-fading to a new piece of music, specified by
# its resource path. Duration, if given, is in seconds.
func cross_fade_to(resource_path:String, duration:float = 1.5):
	if $BGMusicPlayer1.playing && $BGMusicPlayer2.playing:
		# We're busy. Put this song at the end of the queue and switch to it later.
		_cross_fade_queue.push_back(resource_path)
		return

	print("[MusicPlayer] Crossfading into %s" % resource_path)
	var stream:AudioStream = ResourceLoader.load(resource_path)
	# Create a tween to drive the transition between songs, then start playing the
	# new song on whichever player isn't busy.
	_cross_fader = get_tree().create_tween()
	_cross_fader.connect("finished", _on_cross_fade_complete)
	if !$BGMusicPlayer1.playing:
		_cross_fader.tween_method(_update_cross_fade, 0.0, 1.0, duration)
		$BGMusicPlayer1.stream = stream
		$BGMusicPlayer1.play()
	elif !$BGMusicPlayer2.playing:
		_cross_fader.tween_method(_update_cross_fade, 1.0, 0.0, duration)
		$BGMusicPlayer2.stream = stream
		$BGMusicPlayer2.play()
	else:
		assert(false, "Unexpectedly, both music players are playing!")

# Updates the volume of two songs being cross-faded based on a scalar (0 to 1).
# 0.0: $BGMusicPlayer1 is effectively inaudible, $BGMusicPlayer2 is full volume
# 0.5: $BGMusicPlayer1 and $BGMusicPlayer2 are both at half volume
# 1.0: $BGMusicPlayer2 is effectively inaudible, $BGMusicPlayer1 is full volume
func _update_cross_fade(scalar:float) -> void:
	var cross_fade:float = clampf(scalar, 0.0, 1.0)
	$BGMusicPlayer1.volume_db = linear_to_db(cross_fade)
	$BGMusicPlayer2.volume_db = linear_to_db(1.0 - cross_fade)

func _on_cross_fade_complete() -> void:
	_cross_fader = null
	# Stop playing any players which are effectively muted
	if $BGMusicPlayer1.volume_db <= -60.0:
		print("[MusicPlayer] Stopping player 1")
		$BGMusicPlayer1.stop()
	if $BGMusicPlayer2.volume_db <= -60.0:
		print("[MusicPlayer] Stopping player 2")
		$BGMusicPlayer2.stop()
	# If we have any more songs to transition to, start the next one.
	if !_cross_fade_queue.is_empty():
		cross_fade_to(_cross_fade_queue.pop_front())
