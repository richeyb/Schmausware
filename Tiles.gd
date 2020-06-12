extends Node

onready var vertTile = load("res://vert-tile.png")
onready var horizTile = load("res://horiz-tile.png")
onready var emptyTile = load("res://tile-bg.png")
onready var neTile = load("res://ne-tile.png")
onready var seTile = load("res://se-tile.png")
onready var swTile = load("res://sw-tile.png")
onready var nwTile = load("res://nw-tile.png")
onready var exitTile = load("res://gh-logo.png")
onready var startTile = load("res://candidate.png")
onready var badTile = load("res://red_cross.png")
onready var nswTile = load("res://nsw-tile-export.png")
onready var nseTile = load("res://nse-tile-export.png")
onready var newTile = load("res://new-tile-export.png")
onready var neswTile = load("res://nesw-tile-export.png")
onready var sewTile = load("res://sew-tile-export.png")

onready var tiles = [
	emptyTile, # 0
	vertTile, # 1
	horizTile, # 2
	neTile, # 3
	seTile, # 4
	swTile, # 5
	nwTile, # 6
	nswTile, # 7
	nseTile, # 8
	newTile, # 9
	neswTile, # 10
	sewTile, # 11
	exitTile, # 12
	startTile, # 13
	badTile # 14
]

enum Type {
	EMPTY,
	VERT,
	HORIZ,
	NE,
	SE,
	SW,
	NW,
	NSW,
	NSE,
	NEW,
	NESW,
	SEW,
	EXIT,
	START,
	BAD_TILE
}

const TILE_WIDTH = 8
const TILE_HEIGHT = 5
const TILE_SIZE = 32
