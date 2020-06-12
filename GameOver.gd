extends Node2D

onready var finalScoreLabel = $FinalScoreLabel

onready var failHorn = load("res://Price-is-right-losing-horn.wav")
onready var successMusic = load("res://Cheerful Annoyance.ogg")

onready var audioPlayer = $AudioStreamPlayer
const WIN_THRESHOLD = 100

onready var difficultyLabel = $DifficultyLabel

func _ready():
	var difficulties = ["Easy", "Medium", "Hard"]
	difficultyLabel.text = "Difficulty Level: " + difficulties[Scene.difficulty]
	if Scene.difficulty == Scene.Difficulty.HARD:
		difficultyLabel.add_color_override("font_color", Color(1.0, 0.0, 0.0, 1.0))
	elif Scene.difficulty == Scene.Difficulty.MEDIUM:
		difficultyLabel.add_color_override("font_color", Color(1.0, 1.0, 0.0, 1.0))
	else:
		difficultyLabel.add_color_override("font_color", Color(0.0, 1.0, 0.0, 1.0))

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
	Scene.goto_scene("res://TitleScreen.tscn")
