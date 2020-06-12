extends Node2D

onready var tile = preload("res://PipeTile.tscn")

var tiles = []
const TILE_WIDTH = Tiles.TILE_WIDTH
const TILE_HEIGHT = Tiles.TILE_HEIGHT
const TILE_SIZE = Tiles.TILE_SIZE
const OFFSET = 16
const PLACE_TILE_PENALTY = 1
const BONUS = 2
const STAGE_CLEAR_BONUS = 20

export var currentTile = 0

const QUEUE_SIZE = Tiles.TILE_HEIGHT * Tiles.TILE_WIDTH * 5

var tilesPlaced = 0
var pathBonus = 0

onready var ui = get_node("/root/World/UI")

var tileQueue = []

var exitPosition = Vector2(TILE_WIDTH - 1, TILE_HEIGHT - 1)

var startPosition = Vector2(0, 0)
var clears = 0

var walked = []

onready var cursor = get_node("/root/World/Cursor")

func _ready():
	clears = 0
	reset()
	
func getDistance(a, b):
	return abs(floor(b.y) - floor(a.y)) + abs(floor(b.x) - floor(a.x))
	
func reset():
	randomize()
	tiles = []
	tileQueue = []
	tilesPlaced = 0
	startPosition = chooseStartAndExit()
	exitPosition = chooseStartAndExit()
	var distance = getDistance(startPosition, exitPosition)
	#print("1 - Distance is " + str(distance) + " [3, " + str(max(clears * 3, 3)) + "]")
	while distance < 3 || distance > max(clears * 3, 3) || distance < min(max(clears * 2, 3), 10):
		startPosition = chooseStartAndExit()
		exitPosition = chooseStartAndExit()
		distance = getDistance(startPosition, exitPosition)
		#print("2 - Distance is " + str(distance) + " [3, " + str(max(clears * 3, 3)) + "]")
	cursor.moveTo(startPosition.x, startPosition.y)
	clearMap()
	setupTileQueue()
	setUpMap()
	addBadTiles()
	drawMap()
	popTileQueue()
	ui.resetTimer(clears)

func addBadTiles():
	for i in range(clears + 1):
		addBadTile()
	
func addBadTile():
	var x = randi() % (TILE_WIDTH - 2) + 1
	var y = randi() % (TILE_HEIGHT - 2) + 1
	tiles[y][x] = Tiles.Type.BAD_TILE
	
func chooseStartAndExit():
	var x = 0
	var y = 0
	var pos = randi() % 4
	if pos == 0:
		# North wall
		x = randi() % TILE_WIDTH
		y = 0
	elif pos == 1:
		# East wall
		x = TILE_WIDTH - 1
		y = randi() % TILE_HEIGHT
	elif pos == 2:
		# South wall
		y = TILE_HEIGHT - 1
		x = randi() % TILE_WIDTH
	else:
		# West wall
		x = 0
		y = randi() % TILE_HEIGHT
	return Vector2(x, y)

func setupTileQueue():
	randomize()
	var validTiles = []
	if Scene.difficulty == Scene.Difficulty.EASY:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NSW, Tiles.Type.NEW, Tiles.Type.SEW]
	elif Scene.difficulty == Scene.Difficulty.MEDIUM:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ, Tiles.Type.NESW]
	elif Scene.difficulty == Scene.Difficulty.HARD:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ]
	for i in range(QUEUE_SIZE / validTiles.size()):
		var pickFrom = validTiles.duplicate()
		pickFrom.shuffle()
		while pickFrom.size() > 0:
			tileQueue.append(pickFrom.pop_back())

func setUpMap():
	walked = []
	for y in range(TILE_HEIGHT):
		tiles.append([])
		walked.append([])
		for x in range(TILE_WIDTH):
			tiles[y].append(0)
			walked.append(0)
	tiles[startPosition.y][startPosition.x] = Tiles.Type.START
	tiles[exitPosition.y][exitPosition.x] = Tiles.Type.EXIT

func resetWalked():
	walked = []
	for y in range(TILE_HEIGHT):
		walked.append([])
		for x in range(TILE_WIDTH):
			walked[y].append(0)

func clearMap():
	for child in get_children():
		child.queue_free()

func drawMap():
	var y = 0
	var x = 0
	for row in tiles:
		for col in row:
			drawTile(col, x, y)
			x += 1
		y += 1
		x = 0

func drawTile(tileIndex, x, y):
	var newTile = tile.instance()
	newTile.position = Vector2(x * TILE_SIZE + OFFSET, y * TILE_SIZE + OFFSET)
	newTile.tile = tileIndex
	add_child(newTile)

func checkForPath(prev_x, prev_y, x, y, score = 0):
#	var output = "Coming from %s %s, going to %s %s"
#	var fmt_output = output % [str(prev_x), str(prev_y), str(x), str(y)]
#	print(fmt_output)
	if x < 0 or x >= TILE_WIDTH:
		return false
	if y < 0 or y >= TILE_HEIGHT:
		return false
	walked[y][x] = 1
	var tile = tiles[y][x]
	if tile == Tiles.Type.EXIT:
		pathBonus = score
		return true
	match tile:
		Tiles.Type.START:
			return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.EMPTY:
			return false
		Tiles.Type.HORIZ:
			return exitEast(x, y, score) || exitWest(x, y, score)
		Tiles.Type.VERT:
			return exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NE:
			return exitEast(x, y, score) || exitNorth(x, y, score)
		Tiles.Type.NW:
			return exitWest(x, y, score) || exitNorth(x, y, score)
		Tiles.Type.SE:
			return exitEast(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.SW:
			return exitWest(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NESW:
			return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NSE:
			return exitEast(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NSW:
			return exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NEW:
			return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score)
		Tiles.Type.SEW:
			return exitEast(x, y, score) || exitWest(x, y, score) || exitSouth(x, y, score)
		_:
			print("Found tile:" + str(tile))
				
func validExit(x, y, nx, ny, valid, score):
	if invalidExit(nx, ny):
		return false
	if walked[ny][nx] == 1:
		return false
	var t = tiles[ny][nx]
	if valid.has(t):
		return checkForPath(x, y, nx, ny, score + 1)
	else:
		return false
		
func invalidExit(nx, ny):
	return nx < 0 || ny < 0 || ny >= tiles.size() || nx >= tiles[ny].size()

func exitEast(x, y, score = 0):
	var nx = x + 1
	var ny = y
	var valid = [Tiles.Type.NW, Tiles.Type.SW, Tiles.Type.HORIZ, Tiles.Type.EXIT, Tiles.Type.NEW, Tiles.Type.NESW, Tiles.Type.SEW, Tiles.Type.NSW]
	return validExit(x, y, nx, ny, valid, score)
	
func exitWest(x, y, score = 0):
	var nx = x - 1
	var ny = y
	var valid = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.HORIZ, Tiles.Type.EXIT, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NEW, Tiles.Type.SEW]
	return validExit(x, y, nx, ny, valid, score)
	
func exitNorth(x, y, score = 0):
	var nx = x
	var ny = y - 1
	var valid = [Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.VERT, Tiles.Type.EXIT, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NSW, Tiles.Type.SEW]
	return validExit(x, y, nx, ny, valid, score)

func exitSouth(x, y, score = 0):
	var nx = x 
	var ny = y + 1
	var valid = [Tiles.Type.NE, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.EXIT, Tiles.Type.NSW, Tiles.Type.NSE, Tiles.Type.NEW, Tiles.Type.NESW]
	return validExit(x, y, nx, ny, valid, score)

func popTileQueue():
	currentTile = tileQueue.pop_front()
	if tileQueue != null:
		ui.updateTiles(currentTile, tileQueue[0])

func placeTile(x, y):
	if y >= tiles.size() || x >= tiles[y].size():
		return
	if tiles[y][x] == Tiles.Type.BAD_TILE || tiles[y][x] == Tiles.Type.START || tiles[y][x] == Tiles.Type.EXIT:
		return
	
	tiles[y][x] = currentTile
	ui.score -= PLACE_TILE_PENALTY
	clearMap()
	drawMap()
	popTileQueue()
	resetWalked()
	var validPath = checkForPath(0, 0, startPosition.x, startPosition.y)
	if validPath:
		stageCleared()

func _on_ImportTimer_timeout():
	ui.score = ui.score - (tilesPlaced * PLACE_TILE_PENALTY)
	Scene.score = ui.score
	Scene.goto_scene("res://GameOver.tscn")

func stageCleared():
	clears += 1
	reset()
	# Points are:
	# $20mm ARR
	# - (unused tiles * penalty)
	# + (tiles to exit * bonus)
	var difficultyModifier = 1.0
	if Scene.difficulty == Scene.Difficulty.MEDIUM:
		difficultyModifier = 0.8
	elif Scene.difficulty == Scene.Difficulty.EASY:
		difficultyModifier = 0.6
	ui.score = ui.score - ((tilesPlaced - pathBonus) * PLACE_TILE_PENALTY) + STAGE_CLEAR_BONUS + (pathBonus * BONUS) * difficultyModifier
