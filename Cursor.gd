extends Node2D

var x = 0
var y = 0

const TILE_SIZE = 32
const OFFSET = 0

onready var gameBoard = get_node("../GameBoard")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(_delta):
	if Input.is_action_just_pressed("ui_left") && x > 0:
		x -= 1
	elif Input.is_action_just_pressed("ui_right") && x < Tiles.TILE_WIDTH - 1:
		x += 1
	elif Input.is_action_just_pressed("ui_up") && y > 0:
		y -= 1
	elif Input.is_action_just_pressed("ui_down") && y < Tiles.TILE_HEIGHT - 1:
		y += 1
	elif Input.is_action_just_pressed("ui_select"):
		gameBoard.placeTile(x, y)
		
	position = Vector2(x * TILE_SIZE + OFFSET, y * TILE_SIZE + OFFSET)

func _input(event):
	if event is InputEventMouseButton:
		if !event.is_pressed():
			return
		var mousePos = event.position
		var x = (mousePos.x / TILE_SIZE) - OFFSET
		var y = (mousePos.y / TILE_SIZE) - OFFSET
		if x >= 0 && x <= Tiles.TILE_WIDTH - 1 && y >= 0 && y <= Tiles.TILE_HEIGHT - 1:
			gameBoard.placeTile(x, y)
			position = Vector2(x, y)
		
