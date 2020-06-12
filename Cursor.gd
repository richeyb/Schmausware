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
		
	x = min(x, Tiles.TILE_WIDTH - 1)
	y = min(y, Tiles.TILE_HEIGHT - 1)
		
	position = Vector2(x * TILE_SIZE + OFFSET, y * TILE_SIZE + OFFSET)

func _input(event):
	if event is InputEventMouseButton:
		if !event.is_pressed():
			return
		var mousePos = event.position
		var mx = floor(mousePos.x / TILE_SIZE)
		var my = floor(mousePos.y / TILE_SIZE)
		if mx >= Tiles.TILE_WIDTH || my >= Tiles.TILE_HEIGHT:
			return
		x = mx
		y = my
		if x >= 0 && x <= Tiles.TILE_WIDTH && y >= 0 && y <= Tiles.TILE_HEIGHT:
			gameBoard.placeTile(x, y)
			position = Vector2(x * TILE_SIZE + OFFSET, y * TILE_SIZE + OFFSET)
		
func moveTo(nx, ny):
	x = nx
	y = ny
	position = Vector2(x * TILE_SIZE + OFFSET, y * TILE_SIZE + OFFSET)
