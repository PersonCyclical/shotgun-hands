extends Camera2D

@export var follow_in_air: bool = false
@export var static_camera_offset:Vector2 = Vector2(0.,0.)
@export var look_ahead_intensity: float = 50
@export var look_ahead_delta : float = 1.0

@onready var player = $"../2DPlayer"

var camera_look_off: float

func _process(_delta) -> void:
	if not follow_in_air:
		if player.is_on_floor():
			global_position.y = player.global_position.y + static_camera_offset.y
	else:
		global_position.y = player.global_position.y + static_camera_offset.y


	var lookahead:float = -1.0 if float(player.get_node("MovementController").facing_right) == 0 else 1.0
	camera_look_off = move_toward(camera_look_off, lookahead * look_ahead_intensity, look_ahead_delta)
	global_position.x = player.global_position.x + camera_look_off + static_camera_offset.x

