extends Node2D

onready var nextTileImage = $NextTileImage
onready var currentTileImage = $CurrentTileImage
onready var arrLabel = $ARRLabel
onready var nextImportLabel = $NextImportTimer
onready var importTimer = $ImportTimer

var score = 0.0 setget updateScore
const BONUS_TIME = 20

func _ready():
	updateTiles(0, 0)
	
func updateScore(value):
	score = value
	arrLabel.text = "ARR:\n$%5.2fmm" % score

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	nextImportLabel.text = "Next Import:\n%.2f" % importTimer.time_left

func updateTiles(current, next):
	currentTileImage.texture = Tiles.tiles[current]
	nextTileImage.texture = Tiles.tiles[next]

func resetTimer():
	importTimer.start(importTimer.time_left + BONUS_TIME)
