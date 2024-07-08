extends Camera2D

@onready var player = $"../2DPlayer"

func _process(_delta) -> void:
	global_position.x = player.global_position.x
