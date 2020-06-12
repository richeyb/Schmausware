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

onready var tiles = [
	emptyTile,
	vertTile,
	horizTile,
	neTile,
	seTile,
	swTile,
	nwTile,
	exitTile,
	startTile,
	badTile
]

enum Type {
	EMPTY,
	VERT,
	HORIZ,
	NE,
	SE,
	SW,
	NW,
	EXIT,
	START,
	BAD_TILE
}

const TILE_WIDTH = 8
const TILE_HEIGHT = 5
const TILE_SIZE = 32
