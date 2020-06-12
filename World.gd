extends Node2D

onready var audioPlayer = $AudioStreamPlayer

func _ready():
	if Scene.useGreenday:
		audioPlayer.stream = load("res://basket-case.wav")
		audioPlayer.play()
