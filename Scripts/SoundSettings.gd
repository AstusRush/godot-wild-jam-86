extends Node

const settingPath : String = "user://settings.txt"

@export var _sliderSound : Slider
@export var _sliderMusic : Slider

var _sound : float = 0.5
var _music : float = 0.5

func _enter_tree():
	loadSettings()
	_sliderSound.value_changed.connect(_onSoundValueChanged)
	_sliderMusic.value_changed.connect(_onMusicValueChanged)


func _onSoundValueChanged(v : float):
	_sound=v
	SoundSpawner.SpawnFromName("MenuBleep",0.1)
	updateSettings()


func _onMusicValueChanged(v : float):
	_music=v
	updateSettings()

func loadSettings():
	if not FileAccess.file_exists(settingPath):
		print("Create Settings")
		updateSettings() #creates a save file using default values
	
	var access : FileAccess = FileAccess.open(settingPath, FileAccess.READ)

	_sound = float(access.get_var())
	_music = float(access.get_var())
	
	_sliderSound.value=_sound
	_sliderMusic.value=_music

	access.close()
	_updateBus()

func updateSettings():

	print("Setting Update")
	var access : FileAccess = FileAccess.open(settingPath, FileAccess.WRITE)

	access.store_var(_sound)
	access.store_var(_music)

	access.close()
	_updateBus()


func _updateBus():
	AudioServer.set_bus_volume_linear(1,_sound)
	AudioServer.set_bus_volume_linear(2,_music)
