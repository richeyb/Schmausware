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

enum Difficulty {
	EASY,
	MEDIUM,
	HARD
}

export(int) var difficulty = Difficulty.HARD

export var currentTile = 0

const QUEUE_SIZE = Tiles.TILE_HEIGHT * Tiles.TILE_WIDTH

var tilesPlaced = 0
var pathBonus = 0

onready var ui = get_node("/root/World/UI")

var tileQueue = []

var exitPosition = Vector2(TILE_WIDTH - 1, TILE_HEIGHT - 1)

var startPosition = Vector2(0, 0)
var clears = 0

func _ready():
	reset()
	
func reset():
	randomize()
	tiles = []
	tileQueue = []
	tilesPlaced = 0
	clears = 0
	startPosition = chooseStartAndExit()
	exitPosition = chooseStartAndExit()
	while startPosition.distance_to(exitPosition) < 3 && startPosition.distance_to(exitPosition) < clears * 3:
		startPosition = chooseStartAndExit()
		exitPosition = chooseStartAndExit()
	clearMap()
	setupTileQueue()
	setUpMap()
	addBadTiles()
	drawMap()
	popTileQueue()
	ui.resetTimer()

func addBadTiles():
	for i in range(clears + 1):
		addBadTile()
	
func addBadTile():
	var x = randi() % (TILE_WIDTH - 2) + 1
	var y = randi() % (TILE_HEIGHT - 2) + 1
	print("Adding bad tile: " + str(Tiles.Type.BAD_TILE))
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
	if difficulty == Difficulty.EASY:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NSW, Tiles.Type.NEW, Tiles.Type.SEW]
	elif difficulty == Difficulty.MEDIUM:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ, Tiles.Type.NESW]
	elif difficulty == Difficulty.HARD:
		validTiles = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.HORIZ]
	for i in range(QUEUE_SIZE / validTiles.size()):
		var pickFrom = validTiles.duplicate()
		pickFrom.shuffle()
		while pickFrom.size() > 0:
			tileQueue.append(pickFrom.pop_back())

func setUpMap():
	for y in range(TILE_HEIGHT):
		tiles.append([])
		for x in range(TILE_WIDTH):
			#var idx = randi() % 7
			tiles[y].append(0)
	tiles[startPosition.y][startPosition.x] = Tiles.Type.START
	tiles[exitPosition.y][exitPosition.x] = Tiles.Type.EXIT

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
			if prev_x < x && prev_y == y:
				# Coming from the west, exit to the east
				return exitEast(x, y, score)
			else:
				# Coming from the east, exit to the west
				return exitWest(x, y, score)
		Tiles.Type.VERT:
			if prev_y < y:
				# Coming from the north, exit to the south
				return exitSouth(x, y, score)
			else:
				# Coming from the south, exit to the north
				return exitNorth(x, y, score)
		Tiles.Type.NE:
			if prev_x == x:
				# Coming from north, exit to east
				return exitEast(x, y, score)
			else:
				# Coming from east, exit to north
				return exitNorth(x, y, score)
		Tiles.Type.NW:
			if prev_x == x:
				# Coming from north, exit to west
				return exitWest(x, y, score)
			else:
				# Coming from west, exit to north
				return exitNorth(x, y, score)
		Tiles.Type.SE:
			if prev_x == x:
				# Coming from the south, exit to the east
				return exitEast(x, y, score)
			else:
				# Coming from the east, exit to the south
				return exitSouth(x, y, score)
		Tiles.Type.SW:
			if prev_x == x:
				# Coming from the south, exit to the west
				return exitWest(x, y, score)
			else:
				# Coming from the west, exit to the south
				return exitSouth(x, y, score)
		Tiles.Type.NESW:
			if prev_x == x && prev_y < y:
				# Came from the north
				return exitEast(x, y, score) || exitWest(x, y, score) || exitSouth(x, y, score)
			elif prev_x == x && prev_y > y:
				# Came from the south
				return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score)
			elif prev_x < x && prev_y == y:
				# Came from the west
				return exitEast(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
			else:
				# Came from the east
				return exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NSE:
			if prev_x == x && prev_y < y:
				# Came from the north
				return exitEast(x, y, score) || exitWest(x, y, score) || exitSouth(x, y, score)
			elif prev_x == x && prev_y > y:
				# Came from the south
				return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score)
			else:
				# Came from the east
				return exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NSW:
			if prev_x == x && prev_y < y:
				# Came from the north
				return exitEast(x, y, score) || exitWest(x, y, score) || exitSouth(x, y, score)
			elif prev_x == x && prev_y > y:
				# Came from the south
				return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score)
			else:
				# Came from the west
				return exitEast(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.NEW:
			if prev_x == x && prev_y < y:
				# Came from the north
				return exitEast(x, y, score) || exitWest(x, y, score) || exitSouth(x, y, score)
			elif prev_x < x && prev_y == y:
				# Came from the west
				return exitEast(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
			else:
				# Came from the east
				return exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		Tiles.Type.SEW:
			if prev_x == x && prev_y > y:
				# Came from the south
				return exitEast(x, y, score) || exitWest(x, y, score) || exitNorth(x, y, score)
			elif prev_x < x && prev_y == y:
				# Came from the west
				return exitEast(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
			else:
				# Came from the east
				return exitWest(x, y, score) || exitNorth(x, y, score) || exitSouth(x, y, score)
		_:
			print("Found tile:" + str(tile))
				
func exitEast(x, y, score = 0):
	var nx = x + 1
	var ny = y
	if invalidExit(nx, ny):
		return false
	var t = tiles[ny][nx]
	var valid = [Tiles.Type.NW, Tiles.Type.SW, Tiles.Type.HORIZ, Tiles.Type.EXIT, Tiles.Type.NEW, Tiles.Type.NESW, Tiles.Type.SEW, Tiles.Type.NSW]
	if valid.has(t):
		return checkForPath(x, y, nx, ny, score + 1)
	else:
		return false
	
func invalidExit(nx, ny):
	return nx < 0 || ny < 0 || ny >= tiles.size() || nx >= tiles[ny].size()
	
func exitWest(x, y, score = 0):
	var nx = x - 1
	var ny = y
	if invalidExit(nx, ny):
		return false
	var t = tiles[ny][nx]
	var valid = [Tiles.Type.NE, Tiles.Type.SE, Tiles.Type.HORIZ, Tiles.Type.EXIT, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NEW, Tiles.Type.SEW]
	if valid.has(t):
		return checkForPath(x, y, nx, ny, score + 1)
	else:
		return false
	
func exitNorth(x, y, score = 0):
	var nx = x
	var ny = y - 1
	if invalidExit(nx, ny):
		return false
	var t = tiles[ny][nx]
	var valid = [Tiles.Type.SE, Tiles.Type.SW, Tiles.Type.VERT, Tiles.Type.EXIT, Tiles.Type.NESW, Tiles.Type.NSE, Tiles.Type.NSW, Tiles.Type.SEW]
	if valid.has(t):
		return checkForPath(x, y, nx, ny, score + 1)
	else:
		return false

func exitSouth(x, y, score = 0):
	var nx = x 
	var ny = y + 1
	if invalidExit(nx, ny):
		return false
	var t = tiles[ny][nx]
	var valid = [Tiles.Type.NE, Tiles.Type.NW, Tiles.Type.VERT, Tiles.Type.EXIT, Tiles.Type.NSW, Tiles.Type.NSE, Tiles.Type.NEW, Tiles.Type.NESW]
	if valid.has(t):
		return checkForPath(x, y, nx, ny, score + 1)
	else:
		return false

func popTileQueue():
	currentTile = tileQueue.pop_front()
	if tileQueue != null:
		ui.updateTiles(currentTile, tileQueue[0])

func placeTile(x, y):
	if tiles[y][x] == Tiles.Type.BAD_TILE:
		return
	
	tiles[y][x] = currentTile
	ui.score -= PLACE_TILE_PENALTY
	clearMap()
	drawMap()
	popTileQueue()
	var validPath = checkForPath(0, 0, startPosition.x, startPosition.y)
	if validPath:
		stageCleared()

func _on_ImportTimer_timeout():
	print("----- NEW CHECK -----")
	print("Gonna check for a path from the start to the exit now...")
	var validPath = checkForPath(0, 0, startPosition.x, startPosition.y)
	if !validPath:
		gameOver()

func gameOver():
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
	ui.score = ui.score - ((tilesPlaced - pathBonus) * PLACE_TILE_PENALTY) + STAGE_CLEAR_BONUS + (pathBonus * BONUS)
