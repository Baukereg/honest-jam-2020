extends KinematicBody
class_name CustomerInstance
signal removed

enum State {
	ENTER,
	ORDER,
	CONSUME,
	EXIT
}

const GRAVITY = Vector3.DOWN * 40
const WALK_SPEED = 5
const ROTATION_LERP = .1
const INDICATOR_OFFSET = Vector2(0, -100)

onready var _mesh = $Mesh
onready var _animation_player = $AnimationPlayer

var _nodes
var _camera:Camera

var _velocity = Vector3()
var _target_node:Vector2
var _orders:Array = []

var _state_id

##
# @method initialize
# @param {int} customer_id
##
func initialize(customer_id:int, nodes:Array, camera:Camera):
	var customer_data = Customer.data[customer_id]
	_nodes = nodes
	_camera = camera
	
	_mesh.mesh = customer_data.mesh
	
	var num_of_consumes = Utils.choose(customer_data.num_of_consumes)
	for i in num_of_consumes:
		_orders.push_back(Utils.choose(customer_data.consumes))
		
	$ConsumeTimer.one_shot = true
	$ConsumeTimer.wait_time = customer_data.consume_time
	$ConsumeTimer.connect("timeout", self, "_on_consumed")
	
	_set_state(State.ENTER)
	
##
# @method _set_state
# @param {int} state_id
##
func _set_state(state_id:int):
	_state_id = state_id
	
	match _state_id:
		State.ENTER:
			$InteractableArea/CollisionShape.disabled = true
			$OrderIndicator.hide()
			$ConsumableMesh.hide()
			translation.x = _nodes[0].x
			translation.z = _nodes[0].y
			_target_node = _nodes[1]
			_animation_player.play("walk")
			
		State.ORDER:
			var consumable_data = Consumable.data[_orders[0]]
			$InteractableArea/CollisionShape.disabled = false
			$OrderIndicator.show()
			$OrderIndicator/Label.text = tr(consumable_data.name)
			$ConsumableMesh.hide()
			_animation_player.play("idle")
			
		State.CONSUME:
			$InteractableArea/CollisionShape.disabled = true
			$OrderIndicator.hide()
			var consumable_id = _orders.pop_front()
			var consumable_data = Consumable.data[consumable_id]
			$ConsumableMesh.mesh = consumable_data.mesh
			$ConsumableMesh.show()
			$ConsumeTimer.start()
			_animation_player.play("consume")
			
		State.EXIT:
			$ConsumableMesh.hide()
			_animation_player.play("walk")
			
##
# @override
##
func _physics_process(delta):
	if $OrderIndicator.visible:
			$OrderIndicator.position = _camera.unproject_position(translation) + INDICATOR_OFFSET
			
	match _state_id:
		State.ENTER:
			if _move_towards_target_node(delta):
				var next_node_index = _nodes.find(_target_node) + 1
				if next_node_index >= _nodes.size():
					return _set_state(State.ORDER)
				_target_node = _nodes[next_node_index]
				
		State.EXIT:
			if _move_towards_target_node(delta):
				var next_node_index = _nodes.find(_target_node) + 1
				if next_node_index >= _nodes.size():
					emit_signal("removed")
					return queue_free()
				_target_node = _nodes[next_node_index]
			
##
# @method _move_towards_target_node
# @return {bool} true if target node has been reached
##
func _move_towards_target_node(delta):
	var position = Vector2(translation.x, translation.z)
	
	# Get the angle to the next node.
	var angle = position.angle_to_point(_target_node) * -1
	var node_direction = Vector2(-cos(angle), sin(angle))
	
	# Rotate mesh.
	var towards = Utils.normalize_rotate_towards(rotation_degrees.y, rad2deg(angle) + 180) 
	rotation_degrees.y = lerp(rotation_degrees.y, towards, ROTATION_LERP)
	
	# Apply velocity.
	_velocity += GRAVITY * delta
	_velocity.x = node_direction.x * WALK_SPEED
	_velocity.z = node_direction.y * WALK_SPEED
	_velocity = move_and_slide(_velocity, Vector3.UP)
	
	var dist_to_next_node = position.distance_to(_target_node)
	return (dist_to_next_node < 1)
				
##
# @method get_order_consumable_id
# return {int}
##
func get_order_consumable_id():
	if _orders.size() == 0:
		return -1
	return _orders[0]
	
##
# @method consume
##
func consume():
	_set_state(State.CONSUME)
	
##
# @method _on_consumed
##
func _on_consumed():
	_orders.pop_front()
	if _orders.size() > 0:
		return _set_state(State.ORDER)
	
	_nodes.invert()
	_target_node = _nodes[1]
	_set_state(State.EXIT)