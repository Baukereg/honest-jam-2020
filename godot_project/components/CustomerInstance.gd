extends KinematicBody
class_name CustomerInstance
signal puke
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

var _scores:Array
var _wait_times:Array
var _wait_times_queue:Array
var _puke_chance:float = 0

var _state_id

var force_exit:bool = false

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
		
	_scores = customer_data.scores.duplicate()
	_wait_times = customer_data.wait_times
	$WaitTimer.one_shot = true
	$WaitTimer.connect("timeout", self, "_on_wait_expired")
		
	$ConsumeTimer.one_shot = true
	$ConsumeTimer.wait_time = customer_data.consume_time
	$ConsumeTimer.connect("timeout", self, "_on_consumed")
	
	_puke_chance = customer_data.puke_chance
	$PukeTimer.one_shot = true
	$PukeTimer.connect("timeout", self, "_puke")
	
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
			_wait_times_queue = _wait_times.duplicate()
			$WaitTimer.start(_wait_times_queue[0])
			_animation_player.play("idle")
			
		State.CONSUME:
			$InteractableArea/CollisionShape.disabled = true
			$OrderIndicator.hide()
			var consumable_id = _orders.pop_front()
			var consumable_data = Consumable.data[consumable_id]
			$ConsumableMesh.mesh = consumable_data.mesh
			$ConsumableMesh.show()
			$WaitTimer.stop()
			$ConsumeTimer.start()
			_score()
			_animation_player.play("consume")
			
		State.EXIT:
			if _puke_chance > randf():
				$PukeTimer.start(Utils.choose([1, 2, 3]))
			
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
# @method _on_wait_expired
##
func _on_wait_expired():
	_wait_times_queue.pop_front()
	if _wait_times_queue.size() == 0:
		return
	
	$WaitTimer.start(_wait_times_queue[0])
	
##
# @method consume
##
func consume():
	_set_state(State.CONSUME)
	
##
# @method _on_consumed
##
func _on_consumed():
	if _orders.size() == 0 || force_exit:
		_nodes.invert()
		_target_node = _nodes[1]
		_set_state(State.EXIT)
	else:
		_set_state(State.ORDER)
	
##
# @method _emit_score
##
func _score():
	var score = _scores[_wait_times_queue.size()]
	
	if score > 0:
		$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.HAPPY].texture
		$SmileyParticles.amount = score
	elif score < 0:
		$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.UNHAPPY].texture
		$SmileyParticles.amount = abs(score)
	elif score == 0:
		$SmileyParticles.draw_pass_1.material.albedo_texture = Smiley.data[Smiley.NEUTRAL].texture
		$SmileyParticles.amount = 1
	$SmileyParticles.emitting = true
	
	EventBus.publish(EventType.SCORE, {
		"score": score
	})
	
##
# @method _puke
##
func _puke():
	emit_signal("puke", translation)
	