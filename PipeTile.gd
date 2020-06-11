extends Node2D

onready var sprite = $Sprite

export(int) var tile = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.texture = Tiles.tiles[tile]
