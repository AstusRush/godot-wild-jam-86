class_name Paused
extends Control

@export var _btnContinue : Button
@export var _btnRestart : Button
@export var _btnReturn : Button

func _enter_tree():
	visible=false
	Level.paused=self
	Level.enemies.clear()
	get_tree().paused=false
	_btnContinue.pressed.connect(_onBtnContinuePressed)
	_btnRestart.pressed.connect(_onBtnRestartPressed)
	_btnReturn.pressed.connect(_onBtnReturnPressed)

var disableOther : bool

func _onBtnContinuePressed():
	if not visible:
		return
	visible=false
	get_tree().paused=false

func _onBtnRestartPressed():
	if disableOther:
		return
	disableOther=true
	if not visible:
		return
	TransitionManager.EV_TransitionCovered.connect(_onRetryTransitionCovered)
	TransitionManager.TransitionStart()

func _onBtnReturnPressed():
	if disableOther:
		return
	disableOther=true
	TransitionManager.EV_TransitionCovered.connect(_onReturnTransitionCovered)
	TransitionManager.TransitionStart()

func _onRetryTransitionCovered():
	get_tree().reload_current_scene()
func _onReturnTransitionCovered():
	get_tree().paused=false
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")


func _process(delta):
	if TransitionManager.IsTransitioning() or Level.player.isDead():
		return
	if Input.is_action_just_pressed("Paused"):
		if visible: #is paused->unpaused
			visible=false
			get_tree().paused=false
		else: #is unpaused->paused
			visible=true
			get_tree().paused=true

@export var hitstopDuration : float = 0.04
@export var hitstopDurationLong : float = 0.2

func hitstop():
	Engine.time_scale=0.01
	get_tree().create_timer(hitstopDuration,true,false,true).timeout.connect(_onTimeout)
func hitstopLong():
	Engine.time_scale=0.01
	get_tree().create_timer(hitstopDurationLong,true,false,true).timeout.connect(_onTimeout)
func _onTimeout():
	Engine.time_scale=1
