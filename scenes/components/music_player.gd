extends Node2D

var _cross_fader:Tween = null
var _cross_fade_queue:Array = []

func cross_fade_to(resource_path:String):
	if $BGMusicPlayer1.playing && $BGMusicPlayer2.playing:
		_cross_fade_queue.push_back(resource_path)
		return
	
	print("[MusicPlayer] Crossfading into %s" % resource_path)
	var stream:AudioStream = ResourceLoader.load(resource_path)
	if !$BGMusicPlayer1.playing:
		_cross_fader = get_tree().create_tween()
		_cross_fader.connect("finished", _on_cross_fade_complete)
		_cross_fader.tween_method(_update_cross_fade, 0.0, 1.0, 1.5)
		$BGMusicPlayer1.stream = stream
		$BGMusicPlayer1.play()
	elif !$BGMusicPlayer2.playing:
		_cross_fader = get_tree().create_tween()
		_cross_fader.connect("finished", _on_cross_fade_complete)
		_cross_fader.tween_method(_update_cross_fade, 1.0, 0.0, 1.5)
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
	if $BGMusicPlayer1.volume_db <= -60.0:
		print("[MusicPlayer] Stopping player 1")
		$BGMusicPlayer1.stop()
	elif $BGMusicPlayer2.volume_db <= -60.0:
		print("[MusicPlayer] Stopping player 2")
		$BGMusicPlayer2.stop()
	else:
		assert(false, "Neither background music player has volume at or below -60.0db!")
	if !_cross_fade_queue.is_empty():
		cross_fade_to(_cross_fade_queue.pop_front())
