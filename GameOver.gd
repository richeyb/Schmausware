extends Node2D

onready var finalScoreLabel = $FinalScoreLabel

func _ready():
	finalScoreLabel.text = "$%.2f ARR" % Scene.score

func _on_Button_pressed():
	Scene.goto_scene("res://World.tscn")
