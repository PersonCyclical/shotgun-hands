extends Node
class_name AmmoType

# if distance < effective_range[x]:
# 	do damage[x] damage to enemy
# else:
# 	do damage[-1] damage to enemy
# it is begging for a different implementation though ngl
@export var effective_range: Array[float]
@export var damage: Array[float]
@export var max_ammo: int
@onready var ammo: int = max_ammo

@export var _pellet: PackedScene
@export var _pellet_count: int
@export var _pellet_spread_angle: int ## in degrees :pensive:

@export var blast_force: float

var can_fire = true
@export var _cooldown_timer: Timer

var _angle_offsets: Array[float] = []


## returns a list of floats representing the offset for each _pellet
func get_angle_offsets() -> Array[float]:
	if not _angle_offsets.is_empty():
		return _angle_offsets

	var output: Array[float] = []
	if _pellet_count > 1:
		for pellet in range(_pellet_count): # this is so disgusting i'm sorry
			output.append(((-deg_to_rad(_pellet_spread_angle) / 2.0) + \
					(pellet * (deg_to_rad(_pellet_spread_angle) / (_pellet_count - 1.0)))))
	else:
		output = [0]
	_angle_offsets = output
	return _angle_offsets


## returns damage based on passed distance
func get_damage(distance: float) -> float:
	if distance < 0: return -1.0

	if effective_range.is_empty():
		return damage[0]

	for _range in effective_range: # underscore to avoid shadowing "range"
		if distance < _range:
			return damage[effective_range.find(_range)]

	return damage.back()


func _cooldown_timeout() -> void:
	can_fire = true


#region interface

func fire(pivot: Node2D):
	ammo -= 1
	can_fire = false
	_cooldown_timer.start()

	var angle_offsets = get_angle_offsets()

	var hit_info: HitInfo = HitInfo.new()
	for offset in angle_offsets:
		var angle = pivot.global_rotation + offset
		var reticle = pivot.find_child("Reticle")
		var target = reticle.global_position + Vector2.RIGHT.rotated(angle) * 6000.0
		var r_info = _cast_ray(reticle.global_position, target)
		var stop_pos:Vector2
		if r_info:
			hit_info.add_collider(r_info["collider"], reticle.global_position.distance_to(r_info["position"]))
			#if r_info["collider"].get_collision_layer_value(2): # environment
				#print("predict Hit the environment!")
			stop_pos = Vector2(r_info["position"]["x"],r_info["position"]["y"])
		_send_visual_pellet(angle, reticle.global_position,stop_pos,self)

	hit_info.apply_damage(self)


## given an angle offset, sends a ray in the given direction
func _cast_ray(start: Vector2, target: Vector2) -> Dictionary:
	var state = get_viewport().world_2d.direct_space_state
	#only triggers for the environment
	var r_pars = PhysicsRayQueryParameters2D.create(start, target, 0b00_0000_0010) #0b00_0000_0010
	r_pars.collide_with_areas = true
	return state.intersect_ray(r_pars)


## empty for now. may be useful as an interface for different ammo types
func _send_visual_pellet(angle: float, start_pos: Vector2,stop_pos:Vector2, ammo_base:AmmoType):
	var visual = _pellet.instantiate()
	visual.global_position = start_pos
	visual.global_rotation = angle
	visual.stop_pos = stop_pos
	visual.ammo_base = ammo_base
	get_tree().root.add_child(visual)
#endregion

