extends KinematicBody
class_name Player

enum State {
	USER_INPUT,
	ANIMATION,
}

const GRAVITY = Vector3.DOWN * 40
const WALK_OFFSET = deg2rad(-45)
const WALK_SPEED = 10
const ROTATION_SPEED = 8
const TRAY_POSITIONS = [
	Vector3(-.12, .06, -.66),
	Vector3(-.47, .06, 0),
	Vector3(-.24, .06, .68),
	Vector3(.4, .06, .36),
	Vector3(.38, .06, -.34),
]
const INDICATOR_OFFSET = Vector2(0, -100)

var _camera:Camera
var _player_start:Vector3
var _velocity = Vector3()

var _tray_consumable_ids = [ null, null, null, null, null ]
var _tray_consumable_meshes = [ null, null, null, null, null ]

var _interact_id = -1
var _interact_target

var _state_id:int

##
# @method initialize
##
func initialize(camera:Camera):
	_camera = camera
	_player_start = translation
	$InteractIndicator.hide()
	
##
# @method reset
##
func reset():
	translation = _player_start
	
	for mesh in _tray_consumable_meshes:
		if mesh == null: continue
		$TrayMesh.remove_child(mesh)
		mesh.queue_free()
	
	_tray_consumable_ids = [ null, null, null, null, null ]
	_tray_consumable_meshes = [ null, null, null, null, null ]
	
##
# @method _set_state
# @param {int} state_id
##
func _set_state(state_id:int, data = {}):
	_state_id = state_id
	
	match _state_id:
		State.ANIMATION:
			if "name" in data:
				$AnimationPlayer.play(data.name)

##
# @override
##
func _physics_process(delta):
			
	match _state_id:
		State.USER_INPUT:
			_walk_input(delta)
			_interact_input()
	
	if $InteractIndicator.visible:
			$InteractIndicator.position = _camera.unproject_position(translation) + INDICATOR_OFFSET
			
	if Input.is_action_just_pressed("ui_debug"):
		print_debug(translation)
	
##
# @method _walk_input
##
func _walk_input(delta):
	var dir_input = UserInput.get_directional_input().rotated(WALK_OFFSET)
	if dir_input == Vector2.ZERO:
		_velocity.x = 0
		_velocity.z = 0
		$AnimationPlayer.play("idle")
	else:
		var towards = Utils.normalize_rotate_towards(rotation_degrees.y, rad2deg(dir_input.angle() * -1))
		rotation_degrees.y = lerp(rotation_degrees.y, towards, ROTATION_SPEED * delta)
		
		_velocity.x = dir_input.x * WALK_SPEED
		_velocity.z = dir_input.y * WALK_SPEED
		$AnimationPlayer.play("walk")
	
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
			
		Interact.CUSTOMER:
			var customer_instance:CustomerInstance = _interact_target
			var consumable_id = customer_instance.get_order_consumable_id()
			if remove_from_tray(consumable_id):
				customer_instance.consume()
				
		Interact.JUKEBOX:
			var jukebox:Jukebox = _interact_target
			jukebox.reset()
			_set_state(State.ANIMATION, { "name":"kick" })
				
		Interact.PUKE:
			var puke:Puke = _interact_target
			puke.clean_up()
			_set_state(State.ANIMATION, { "name":"mop" })
	
##
# @method add_to_tray
# @param {int} consumable_id
##
func add_to_tray(consumable_id:int):
	var consumable_data = Consumable.data[consumable_id]
	
	# Check if tray is empty.
	if !_tray_consumable_ids.has(null):
		return
		
	# Get random position.
	var positions = range(_tray_consumable_ids.size())
	positions.shuffle()
	while positions.size() > 0 && _tray_consumable_ids[positions[0]] != null:
		positions.pop_front()
	var position = positions[0]
		
	# Create mesh.
	var mesh:MeshInstance = MeshInstance.new()
	$TrayMesh.add_child(mesh)
	mesh.translation = TRAY_POSITIONS[position]
	mesh.mesh = consumable_data.mesh
	
	_tray_consumable_ids[position] = consumable_id
	_tray_consumable_meshes[position] = mesh
	
##
# @method remove_from_tray
# @param {int} consumable_id
# @return {bool} true if removed
##
func remove_from_tray(consumable_id:int):
	if !_tray_consumable_ids.has(consumable_id):
		return false
		
	var positions = range(_tray_consumable_ids.size())
	positions.shuffle()
	while positions.size() > 0 && _tray_consumable_ids[positions[0]] != consumable_id:
		positions.pop_front()
		
	var mesh = _tray_consumable_meshes[positions[0]]
	$TrayMesh.remove_child(mesh)
	mesh.queue_free()
	_tray_consumable_meshes[positions[0]] = null
	_tray_consumable_ids[positions[0]] = null
	
	return true
	
##
# @method _on_animation_finished
# @param {String} anim_name
##
func _on_animation_finished(anim_name:String):
	if _state_id == State.ANIMATION:
		_set_state(State.USER_INPUT)
	
##
# @method _on_interact_area_entered
##
func _on_interact_area_entered(area):
	var interact_id = area.get_interact_id()
	if _interact_id != interact_id:
		_set_interact(area.get_parent(), interact_id)
	
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
func _set_interact(target, interact_id:int):
	# Remove old.
	if _interact_id != -1:
		$InteractIndicator.hide()
		
	_interact_target = target
	_interact_id = interact_id
	
	if _interact_id != -1:
		var interact_data = Interact.data[_interact_id]
		$InteractIndicator/Label.text = tr(interact_data.name)
		$InteractIndicator.position = _camera.unproject_position(translation) + INDICATOR_OFFSET
		$InteractIndicator.show()
