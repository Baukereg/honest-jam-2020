extends KinematicBody
class_name Cat

const GRAVITY = Vector3.DOWN * 60
const RUN_INTERVAL = [ 8, 16 ]
const RUN_SPEED = 30

var _velocity = Vector3()
var _nodes:Array
var _target_node:Vector2
var _active:bool = false
var _running:bool = false

##
# @override
##
func _ready():
	hide()
	$Timer.one_shot = true
	$Timer.connect("timeout", self, "_on_timer")
	
# @method initialize
# @param {bool} active
# @param {Array} nodes
##
func initialize(nodes:Array = []):
	_nodes = nodes

##
# @method initialize
# @param {bool} active
##
func activate(active:bool):
	_active = active
	
	if _active:
		restart()
	else:
		$Timer.stop()
		hide()
	
##
# @method restart
##
func restart():
	show()
	_running = false
	
	if Utils.chance(.5):
		_nodes.invert()
	translation.x = _nodes[0].x
	translation.z = _nodes[0].y
	_target_node = _nodes[1]
	
	$Timer.start(Utils.irand_range(RUN_INTERVAL[0], RUN_INTERVAL[1]))
	
##
# method _on_timer
##
func _on_timer():
	_running = true

##
# @override
##
func _physics_process(delta):
	if !_running:
		return
	
	var move_results = MoveUtils._move_towards(delta, self, _velocity, _target_node, RUN_SPEED)
	_velocity = move_results.velocity
	if move_results.dist_to_target < 1:
		var next_index = _nodes.find(_target_node) + 1
		if next_index < _nodes.size():
			_target_node = _nodes[next_index]
			return
		else:
			restart()
		