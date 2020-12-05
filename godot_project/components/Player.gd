extends KinematicBody
class_name Player

const GRAVITY = Vector3.DOWN * 40
const WALK_SPEED = 8
const ROTATION_SPEED = 8
const TRAY_POSITIONS = [
	Vector3(-.12, .06, -.66),
	Vector3(-.47, .06, 0),
	Vector3(-.24, .06, .68),
	Vector3(.4, .06, .36),
	Vector3(.38, .06, -.34),
]

export(float) var movement_offset = 0

onready var _collision_shape = $CollisionShape
onready var _mesh = $Mesh
onready var _tray_mesh = $Tray
onready var _animation_player = $AnimationPlayer

var _velocity = Vector3()
var _dir_input:Vector2 = Vector2.ZERO

var _tray_consumables = [ null, null, null, null, null ]
var _interact_area = null
var _interact_id = -1

##
# @override
##
func _physics_process(delta):
	_walk_input(delta)
	_interact_input()
	
##
# @method _walk_input
##
func _walk_input(delta):
	_dir_input = UserInput.get_directional_input().rotated(movement_offset)
	if _dir_input == Vector2.ZERO:
		_velocity.x = 0
		_velocity.z = 0
		_animation_player.play("idle")
	else:
		var towards = Utils.normalize_rotate_towards(rotation_degrees.y, rad2deg(_dir_input.angle() * -1))
		rotation_degrees.y = lerp(rotation_degrees.y, towards, ROTATION_SPEED * delta)
		
		_velocity.x = _dir_input.x * WALK_SPEED
		_velocity.z = _dir_input.y * WALK_SPEED
		_animation_player.play("walk")
	
	_velocity += GRAVITY * delta
	_velocity = move_and_slide(_velocity, Vector3.UP)
		
##
# @method _interact_input
##
func _interact_input():
	if !Input.is_action_just_pressed("ui_accept"):
		return
		
	match _interact_id:
		Interact.BEER_TAP:
			add_to_tray(Consumable.BEER)
			
		Interact.COFFEE_MACHINE:
			add_to_tray(Consumable.COFFEE)
	
##
# @method add_to_tray
##
func add_to_tray(consumable_id:int):
	var consumable_data = Consumable.data[consumable_id]
	
	# Check if tray is empty.
	if !_tray_consumables.has(null):
		return
		
	# Get random position.
	var positions = range(_tray_consumables.size())
	positions.shuffle()
	while positions.size() > 0 && _tray_consumables[positions[0]] != null:
		positions.pop_front()
	var position = positions[0]
		
	# Create mesh.
	var mesh:MeshInstance = MeshInstance.new()
	_tray_mesh.add_child(mesh)
	mesh.translation = TRAY_POSITIONS[position]
	mesh.mesh = consumable_data.mesh
	
	_tray_consumables[position] = consumable_id
	
##
# @method _on_interact_area_entered
##
func _on_interact_area_entered(area):
	var interact_id = area.get_interact_id()
	if _interact_id != interact_id:
		_set_interact(area, interact_id)
	
##
# @method _on_interact_area_exited
##
func _on_interact_area_exited(area):
	var interact_id = area.get_interact_id()
	if _interact_id == interact_id:
		_set_interact(null, -1)
	
##
# @method _set_interact
##
func _set_interact(area:Area, interact_id:int):
	# Remove old.
	if _interact_id != -1:
		pass
		
	_interact_area = area
	_interact_id = interact_id
	
	if _interact_id != -1:
		var interact_data = Interact.data[_interact_id]
