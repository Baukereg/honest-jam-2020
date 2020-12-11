extends KinematicBody
class_name Player

enum State {
	USER_INPUT,
	ANIMATION,
	MOUSE_FLEE,
}

const GRAVITY = Vector3.DOWN * 60
const WALK_OFFSET = deg2rad(-45)
const WALK_SPEED = 13
const ROTATION_SPEED = 10
const ROTATION_LERP = .1
const TRAY_POSITIONS = [
	Vector3(-.12, .06, -.66),
	Vector3(-.47, .06, 0),
	Vector3(-.24, .06, .68),
	Vector3(.4, .06, .36),
	Vector3(.38, .06, -.34),
]
const INDICATOR_OFFSET = Vector2(0, -80)
const MOUSE_FLEE_POSITION = Vector2(24, 5.5)

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
# @param {Camera} camera
##
func initialize(camera:Camera):
	_camera = camera
	_player_start = translation
	$InteractIndicator.hide()
	$Eeek.hide()
	
##
# @method reset
##
func reset():
	translation = _player_start
	_reset_tray()
	
##
# @method _reset_tray
##
func _reset_tray():
	for mesh in _tray_consumable_meshes:
		if mesh == null: continue
		$TrayMesh.remove_child(mesh)
		mesh.queue_free()
	
	_tray_consumable_ids = [ null, null, null, null, null ]
	_tray_consumable_meshes = [ null, null, null, null, null ]
	
##
# @method _set_state
# @param {int} state_id
# @param {Object} data
##
func _set_state(state_id:int, data = {}):
	_state_id = state_id
	$MopMesh.hide()
	$Eeek.hide()
	
	match _state_id:
		State.ANIMATION:
			if "name" in data:
				$AnimationPlayer.play(data.name)
				
		State.MOUSE_FLEE:
			$AnimationPlayer.play("walk")
			$Eeek.show()

##
# @override
##
func _physics_process(delta):
	match _state_id:
		State.USER_INPUT:
			_walk_input(delta)
			_interact_input()
			
		State.MOUSE_FLEE:
			var move_results = MoveUtils._move_towards(delta, self, _velocity, MOUSE_FLEE_POSITION, WALK_SPEED)
			_velocity = move_results.velocity
			if move_results.dist_to_target < 1:
				$Eeek.hide()
				return _set_state(State.USER_INPUT)
	
	if $InteractIndicator.visible:
			$InteractIndicator.position = (_camera.unproject_position(translation) + INDICATOR_OFFSET).round()
	if $Eeek.visible:
			$Eeek.position = (_camera.unproject_position(translation) + INDICATOR_OFFSET).round()
	
##
# @method _walk_input
# @param {float} delta
##
func _walk_input(delta:float):
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
		
	if _interact_id == -1 || _interact_id == Interact.MOUSE:
		return
		
	MoveUtils.instant_rotate_towards(
		self, Vector2(_interact_target.translation.x, _interact_target.translation.z)
	)
		
	match _interact_id:
		Interact.BEER_TAP:
			if add_to_tray(Consumable.BEER):
				_interact_target.interacted()
				_set_state(State.ANIMATION, { "name":"interact" })
			
		Interact.COFFEE_MACHINE:
			if add_to_tray(Consumable.COFFEE):
				_interact_target.interacted()
				_set_state(State.ANIMATION, { "name":"interact" })
			
		Interact.WINE_RACK:
			if add_to_tray(Consumable.WINE):
				_set_state(State.ANIMATION, { "name":"interact" })
			
		Interact.CUSTOMER:
			var customer_instance:CustomerInstance = _interact_target
			var consumable_id = customer_instance.get_order_consumable_id()
			if remove_from_tray(consumable_id):
				customer_instance.consume()
				_set_state(State.ANIMATION, { "name":"interact" })
				
		Interact.JUKEBOX:
			var jukebox:Jukebox = _interact_target
			if jukebox.is_active():
				jukebox.restart()
				$StarParticles.emitting = true
				_set_state(State.ANIMATION, { "name":"kick" })
				
		Interact.PUKE:
			var puke:Puke = _interact_target
			puke.clean_up()
			$InteractIndicator.hide()
			_set_state(State.ANIMATION, { "name":"mop" })
			
		Interact.MOUSE:
			var mouse:Mouse = _interact_target
				
		Interact.ARCADE:
			var customer_instance:CustomerInstance = _interact_target
			customer_instance.end_arcade()
			$StarParticles.emitting = true
			_set_state(State.ANIMATION, { "name":"kick" })
	
##
# @method add_to_tray
# @param {int} consumable_id
# @return {bool}
##
func add_to_tray(consumable_id:int):
	var consumable_data = Consumable.data[consumable_id]
	
	# Check if tray is full.
	if !_tray_consumable_ids.has(null):
		return false
		
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
	
	if !_tray_consumable_ids.has(null):
		$InteractIndicator.hide()
		
	return true
	
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
	if _interact_id == interact_id:
		return
			
	_set_interact(area.get_parent(), interact_id)
	
##
# @method _on_interact_area_exited
# @param {Area} area
##
func _on_interact_area_exited(area):
	var interact_id = area.get_interact_id()
	if _interact_id == interact_id:
		_set_interact(null, -1)
	
##
# @method _set_interact
# @param {Spatial} target
# @param {int} interact_id
##
func _set_interact(target, interact_id:int):
	# Remove old.
	if _interact_id != -1:
		$InteractIndicator.hide()
		
	_interact_target = target
	_interact_id = interact_id
	
	if _interact_id == -1:
		return
		
	var interact_data = Interact.data[_interact_id]
	
	if interact_id == Interact.COFFEE_MACHINE || interact_id == Interact.BEER_TAP || interact_id == Interact.WINE_RACK:
		if !_tray_consumable_ids.has(null):
			return
	
	if interact_id == Interact.CUSTOMER:
		var customer:CustomerInstance = _interact_target
		var consumable_id = customer.get_order_consumable_id()
		if !_tray_consumable_ids.has(consumable_id):
			return
		var consumable_data = Consumable.data[consumable_id]
		interact_data.icon = consumable_data.icon
		
	if _interact_id == Interact.MOUSE:
		var mouse:Mouse = _interact_target
		if mouse.mouse_is_active():
			return _set_state(State.MOUSE_FLEE)
		return
			
	if _interact_id == Interact.CAT:
		_reset_tray()
		$StarParticles.emitting = true
		_set_state(State.ANIMATION, { "name":"drop" })
	
	if _state_id != State.USER_INPUT:
		return
	
	if "text" in interact_data:
		$InteractIndicator/Label.text = tr(interact_data.text)
	if "icon" in interact_data:
		$InteractIndicator/Icon.texture = interact_data.icon
	$InteractIndicator.position = _camera.unproject_position(translation) + INDICATOR_OFFSET
	$InteractIndicator.show()
