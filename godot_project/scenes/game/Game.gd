extends Spatial

enum State {
	BEFORE,
	OPEN,
	AFTER
}

const OPEN_TIME = 120
const FIRST_SPAWN_TIME = 2
const SPAWN_TIME = 10

onready var _customer_instance_resource = preload("res://components/CustomerInstance.tscn")
onready var _puke_resource = preload("res://components/Puke.tscn")

onready var _player_start:Vector3
onready var _nodes = $Nodes.get_children()
onready var _paths;

var _day:int = 0
var _time:float
var _score:int = 0
var _state_id:int

##
# @override
##
func _ready():
	randomize()
	
	$AfterMenu.connect("close", self, "_set_state", [ State.BEFORE ])
	
	$Player.initialize($CameraControl/Camera)
	$CameraControl.set_target($CenterPoint)
	
	_paths = []
	for i in range(CustomerPath.data.size()):
		_paths.push_back(false)
	$Nodes.hide()
	
	$OpenTimer.one_shot = false
	$SpawnCostumerTimer.connect("timeout", self, "spawn_customer")
	
	$OpenTimer.one_shot = true
	$OpenTimer.wait_time = OPEN_TIME
	$OpenTimer.connect("timeout", self, "_on_time_up")
	
	EventBus.subscribe(EventType.SCORE, self, "_on_score")
	_set_state(State.BEFORE)
	
##
# @override
##
func _exit_tree():
	EventBus.unsubscribe(EventType.SCORE, self, "_on_score")
	
##
# @method _set_state
# @param {int} state_id
##
func _set_state(state_id:int):
	_state_id = state_id
	
	match _state_id:
		State.BEFORE:
			_day += 1
			$Progress/DayLabel.text = "Day " + str(_day) + "/5"
			$Player.reset()
			for puke in $Puke.get_children():
				$Puke.remove_child(puke)
				$Puke.queue_free()
			
			return _set_state(State.OPEN)
			
		State.OPEN:
			$Progress.show()
			$SpawnCostumerTimer.start(FIRST_SPAWN_TIME)
			$OpenTimer.start()
			$Bar/Jukebox.reset()
			
		State.AFTER:
			$Progress.hide()
			$AfterMenu.start()
			$Bar/Jukebox.reset(true)
	
##
# @override
##
func _physics_process(delta):
	if Input.is_action_just_released("ui_pause"):
		$PauseMenu.start()
		
	$Progress/TimeLabel.text = "Time " + str(ceil($OpenTimer.time_left)) + "s"
		
##
# @method spawn_customer
##
func spawn_customer():
	print_debug($SpawnCostumerTimer.wait_time)
	if $SpawnCostumerTimer.wait_time == FIRST_SPAWN_TIME:
		$SpawnCostumerTimer.start(SPAWN_TIME)
		
	if !_paths.has(false):
		return
		
	# Get random path.
	var paths = range(_paths.size())
	paths.shuffle()
	while paths.size() > 0 && _paths[paths[0]] == true:
		paths.pop_front()
	var path_id = paths[0]
	_paths[path_id] = true
	
	# Create nodes.
	var path_data = CustomerPath.data[path_id]
	var nodes = []
	for i in path_data.nodes:
		nodes.push_back(Vector2(_nodes[i].translation.x, _nodes[i].translation.z))
	
	var customer_id = Utils.irand_range(0, Customer.data.size() - 1)
	var customer = _customer_instance_resource.instance()
	$Customers.add_child(customer)
	customer.initialize(customer_id, nodes, $CameraControl/Camera)
	customer.connect("puke", self, "_spawn_puke")
	customer.connect("removed", self, "_on_customer_removed", [ path_id ])
	
##
# @method _on_customer_removed
# @param {int} path_id
##
func _on_customer_removed(path_id):
	_paths[path_id] = false
	if $OpenTimer.is_stopped() && !_paths.has(true):
		_set_state(State.AFTER)
		
##
# @method _spawn_puke
# @param {Vector3} trans
##
func _spawn_puke(trans:Vector3):
	var puke = _puke_resource.instance()
	puke.translation = trans
	puke.translation.y = .1
	$Puke.add_child(puke)
	
##
# @method _on_time_up
##
func _on_time_up():
	$SpawnCostumerTimer.stop()
	for customer in $Customers.get_children():
		customer.force_exit = true
	
##
# @method _on_score
##
func _on_score(data):
	_score += data.score
	$Progress/ScoreLabel.text = "Score " + str(_score)
	