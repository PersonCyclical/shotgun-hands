extends Node2D
#defined externally
@export var _pellet_speed: float = 0;

var stop_pos:Vector2;
func _physics_process(_delta):
	var temp = global_position;
	global_position += Vector2.RIGHT.rotated(rotation) * _pellet_speed
	var unset_vec2 :Vector2;
	if stop_pos != unset_vec2:
		#there are better ways to do this
		if temp.distance_squared_to(stop_pos) < global_position.distance_squared_to(stop_pos):
			destroy()
#called by DestroyTimer, HACK that assumes it doesn't hit something off screen
func destroy():
	#print("assumed ",stop_pos," true ",global_position)
	queue_free()
