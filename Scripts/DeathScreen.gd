extends Control

@export var _deathMessageLabel : RichTextLabel

@export var _statTimeAlive : RichTextLabel
@export var _statKillCount : RichTextLabel

@export var _retryPromptLabel : RichTextLabel
@export var _btnRetry : Button
@export var _btnReturn : Button

func _enter_tree():
	visible=false

func _ready():
	Level.player.EV_death.connect(_onDeath)
	_btnRetry.pressed.connect(_onBtnRetryPressed)
	_btnReturn.pressed.connect(_onBtnReturnPressed)



func _onDeath():
	_statTimeAlive.text="[center]" + str(int(Level.stats.playtime)) + " SECONDS"
	_statKillCount.text="[center]" + str(int(Level.stats.kills)) + " KILLS"
	visible=true

func _onBtnRetryPressed():
	TransitionManager.EV_TransitionCovered.connect(_onRetryTransitionCovered)
	TransitionManager.TransitionStart()
func _onBtnReturnPressed():
	TransitionManager.EV_TransitionCovered.connect(_onReturnTransitionCovered)
	TransitionManager.TransitionStart()

func _process(delta: float):
	if visible and Input.is_action_just_pressed("Paused"):
		_onBtnReturnPressed()

func _onRetryTransitionCovered():
	get_tree().reload_current_scene()

func _onReturnTransitionCovered():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
