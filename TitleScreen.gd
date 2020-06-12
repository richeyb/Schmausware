extends Node2D

onready var audioPlayer = $AudioStreamPlayer
onready var paradiseMusic = load("res://paradise.wav")
onready var normalMusic = load("res://title-screen-music.wav")

func _ready():
	playMusic()

func _on_HardButton_pressed():
	Scene.difficulty = Scene.Difficulty.HARD
	Scene.goto_scene("res://World.tscn")

func _on_MediumButton2_pressed():
	Scene.difficulty = Scene.Difficulty.MEDIUM
	Scene.goto_scene("res://World.tscn")

func _on_EasyButton_pressed():
	Scene.difficulty = Scene.Difficulty.EASY
	Scene.goto_scene("res://World.tscn")

func _on_CheckBox_toggled(button_pressed):
	Scene.useGreenday = button_pressed
	playMusic()

func playMusic():
	if Scene.useGreenday:
		audioPlayer.stream = paradiseMusic
		audioPlayer.play()
	else:
		audioPlayer.stream = normalMusic
		audioPlayer.play()
