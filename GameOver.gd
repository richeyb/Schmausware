extends Node2D

onready var finalScoreLabel = $FinalScoreLabel

onready var failHorn = load("res://Price-is-right-losing-horn.wav")
onready var successMusic = load("res://Cheerful Annoyance.ogg")

onready var audioPlayer = $AudioStreamPlayer
const WIN_THRESHOLD = 100

func _ready():
	finalScoreLabel.text = "$%.2fmm ARR" % Scene.score
	if Scene.score > WIN_THRESHOLD:
		audioPlayer.stream = successMusic
		audioPlayer.play()
		finalScoreLabel.add_color_override("font_color", Color(0.0, 1.0, 0.0, 1.0))
	else:
		audioPlayer.stream = failHorn
		audioPlayer.play()
		finalScoreLabel.add_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))

func _on_Button_pressed():
	Scene.goto_scene("res://World.tscn")
