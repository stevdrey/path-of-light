extends AudioStreamPlayer

const GAME_TRACK: AudioStreamWAV = preload("res://assets/sounds/music/background_sfx_engine.wav")
const MENU_TRACK: AudioStreamWAV = preload("res://assets/sounds/music/menu_theme.wav")

func _ready() -> void:
	bus = &"Music"
	play_game()

func play_menu() -> void:
	_play_track(MENU_TRACK)

func play_game() -> void:
	_play_track(GAME_TRACK)

func _play_track(track: AudioStreamWAV) -> void:
	var looping_track := track.duplicate() as AudioStreamWAV
	looping_track.loop_mode = AudioStreamWAV.LOOP_FORWARD
	looping_track.loop_begin = 0
	looping_track.loop_end = roundi(track.get_length() * track.mix_rate)
	stream = looping_track
	play()
