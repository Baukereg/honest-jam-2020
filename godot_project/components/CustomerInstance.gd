extends KinematicBody
class_name CustomerInstance
signal puke
signal remove

enum State {
	ENTER,
	ORDER,
	CONSUME,
	ARCADE,
	EXIT
}

const GRAVITY = Vector3.DOWN * 40
const WALK_SPEED = 7
const ROTATION_LERP = .1
const INDICATOR_OFFSET = Vector2(0, -80)
const ARCADE_WAIT_TIME = 5
const ARCADE_SCORES = [ -3, -2, -1 ]

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
var _option_id = -1
var _chillout_mode:bool = false

var _state_id
var _exit_forced:bool = false

var enable_arcade:bool = false

##
# @method initialize
# @param {int} customer_id
# @param {Array} nodes
# @param {Camera} camera
# @param {bool} can_puke
##
func initialize(customer_id:int, nodes:Array, camera:Camera, can_puke:bool):
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
	
	_puke_chance = 0 if !can_puke else customer_data.puke_chance
	$PukeTimer.one_shot = true
	$PukeTimer.connect("timeout", self, "_puke")
	
	$ArcadeTimer.connect("timeout", self, "_on_arcade")
	$PuffParticles.emitting = false
	
	_set_state(State.ENTER)
	
##
# @method set_option
# @param {int} option_id
##
func set_option(option_id:int):
	_option_id = option_id
	
##
# @method set_chillout_mode
# @param {bool} value
##
func set_chillout_mode(value:bool):
	_chillout_mode = value
	
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
			$OrderIndicator/Icon.texture = consumable_data.icon
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
			if _chillout_mode:
				_score(1)
			else:
				_score(_scores[_wait_times_queue.size()])
			_animation_player.play("consume")
			
		State.ARCADE:
			$AnimationPlayer.play("angry")
			$ConsumableMesh.hide()
			$PuffParticles.emitting = true
			$ArcadeTimer.start(ARCADE_WAIT_TIME)
			$InteractableArea.interact_id = Interact.ARCADE
			$InteractableArea/CollisionShape.disabled = false
			FxPlayer.play(Fx.GROAN)
			
		State.EXIT:
			$InteractableArea/CollisionShape.disabled = true
			_nodes.invert()
			_target_node = _nodes[1]
		
			$WaitTimer.stop()
			$ConsumeTimer.stop()
			if !_exit_forced && _puke_chance > randf():
				$PukeTimer.start(Utils.choose([1, 2, 3]))
			
			$OrderIndicator.hide()
			$ConsumableMesh.hide()
			_animation_player.play("walk")
			
##
# @override
##
func _physics_process(delta):
	if $OrderIndicator.visible:
			$OrderIndicator.position = (_camera.unproject_position(translation) + INDICATOR_OFFSET).round()
			
	match _state_id:
		State.ENTER:
			if _move_towards_target_node(delta):
				return _set_state(State.ORDER)
				
		State.EXIT:
			if _move_towards_target_node(delta):
				emit_signal("remove")
				return
			
##
# @method _move_towards_target_node
# @return {bool} true if end of the nodes queue has been reached
##
func _move_towards_target_node(delta):
	var move_results = MoveUtils._move_towards(delta, self, _velocity, _target_node, WALK_SPEED)
	_velocity = move_results.velocity
	
	if move_results.dist_to_target < 1:
		var next_node_index = _nodes.find(_target_node) + 1
		if next_node_index >= _nodes.size():
			return true
		_target_node = _nodes[next_node_index]
	
	return false
				
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
	if _orders.size() == 0 || _exit_forced:
		if enable_arcade && !_exit_forced && _option_id == CustomerOption.ARCADE:
			return _set_state(State.ARCADE)
		return _set_state(State.EXIT)
	
	_set_state(State.ORDER)
	
##
# @method _puke
##
func _puke():
	if !_exit_forced:
		emit_signal("puke", translation)
	
##
# @method _on_arcade
##
func _on_arcade():
	_score(Utils.choose(ARCADE_SCORES))
	
##
# method end_arcade
##
func end_arcade():
	if _state_id == State.ARCADE:
		$ArcadeTimer.stop()
		$InteractableArea/CollisionShape.disabled = true
		$PuffParticles.emitting = false
		_set_state(State.EXIT)
		
##
# @method force_exit
##
func force_exit():
	_exit_forced = true
	
	if _state_id != State.EXIT:
		var score = _scores[_wait_times_queue.size()]
		if score < 0:
			_score(score)
		_set_state(State.EXIT)
	
##
# @method _emit_score
# @param {int} score
##
func _score(score:int):
	if _chillout_mode:
		$HeartParticles.amount = 5
		$HeartParticles.emitting = true
		return
	
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
