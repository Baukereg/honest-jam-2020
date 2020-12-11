extends Spatial

enum State {
	BEFORE,
	OPEN,
	AFTER
}

const OPEN_TIME = 90.0
const FIRST_SPAWN_TIME = 2

onready var _customer_instance_resource = preload("res://components/CustomerInstance.tscn")
onready var _puke_resource = preload("res://components/Puke.tscn")

onready var _nodes = $Nodes.get_children()
onready var _paths;

var _stage_id:int = -1
var _stage_data
var _score
var _scores_by_stage:Array = []
var _streak = 0

var _state_id:int
var _customers:Array = []

##
# @override
##
func _ready():
	randomize()
	
	$BeforeMenu.connect("completed", self, "_set_state", [ State.OPEN ])
	$AfterMenu.connect("completed", self, "_set_state", [ State.BEFORE ])
	
	$Player.initialize($CameraControl/Camera)
	$CameraControl.set_target($CenterPoint)
	
	_paths = []
	for i in range(CustomerPath.data.size()):
		_paths.push_back(false)
	$Nodes.hide()
	
	var cat_nodes = $CatNodes.get_children()
	for i in range(cat_nodes.size()):
		var node = Vector2(cat_nodes[i].translation.x, cat_nodes[i].translation.z)
		cat_nodes[i] = node
	$Bar/Cat.initialize(cat_nodes)
	
	$OpenTimer.one_shot = false
	$SpawnCostumerTimer.connect("timeout", self, "_spawn_customer")
	
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
			_stage_id += 1
			if _stage_id >= Stage.data.size():
				_end()
				return
			
			_stage_data = Stage.data[_stage_id]
			_score = {
				"positive": 0,
				"neutral": 0,
				"negative": 0,
				"streak": 0
			}
			_on_score({ "score":-999 })
			$Progress.hide()
			$Bar/Jukebox.activate(false)
			
			for puke in $Puke.get_children():
				$Puke.remove_child(puke)
				puke.queue_free()
			
			$BeforeMenu.start(_stage_id + 1)
			#return _set_state(State.OPEN)
			
		State.OPEN:
			$Progress.show()
			$SpawnCostumerTimer.start(FIRST_SPAWN_TIME)
			$OpenTimer.start()
			$Bar/Jukebox.activate(_stage_data.enabled_interacts.has(Interact.JUKEBOX))
			$Bar/Mouse.set_enabled(_stage_data.enabled_interacts.has(Interact.MOUSE))
			$Bar/Cat.activate(_stage_data.enabled_interacts.has(Interact.CAT))
			
		State.AFTER:
			$Progress.hide()
			$Player.reset()
			$Bar/Jukebox.activate(false)
			
			_on_score({ "score":-999 })
			_scores_by_stage.push_back(_score)
			$AfterMenu.start(_score)
	
##
# @override
##
func _physics_process(delta):
	if Input.is_action_just_released("ui_pause"):
		$PauseMenu.start()
		
	$Progress/TimeLabel.text = "Time " + str(ceil($OpenTimer.time_left)) + "s"
		
##
# @method _spawn_customer
##
func _spawn_customer():
	var spawn_time_range = _stage_data.spawn_time[0] - _stage_data.spawn_time[1]
	var time_perc =  1.0 - $OpenTimer.time_left / OPEN_TIME
	var mod = floor(spawn_time_range * time_perc)
	var spawn_time = _stage_data.spawn_time[0] - mod
	$SpawnCostumerTimer.start(spawn_time)
		
	# Stop if no paths are available.
	if !_paths.has(false):
		return
		
	# Stop if max customers is reached.
	if _customers.size() >= _stage_data.max_customers:
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
		
	var can_puke = _stage_data.enabled_interacts.has(Interact.PUKE)
	
	# Create customer.
	var customer_id = Utils.irand_range(0, Customer.data.size() - 1)
	var customer = _customer_instance_resource.instance()
	$Customers.add_child(customer)
	_customers.push_back(customer)
	customer.initialize(customer_id, nodes, $CameraControl/Camera, can_puke)
	if "customer_option_id" in path_data:
		customer.set_option(path_data.customer_option_id)
	customer.enable_arcade = _stage_data.enabled_interacts.has(Interact.ARCADE)
	customer.connect("puke", self, "_spawn_puke")
	customer.connect("remove", self, "_on_customer_remove", [ customer, path_id ])
	
##
# @method _on_customer_removed
# @param {Customer} customer
# @param {int} path_id
##
func _on_customer_remove(customer, path_id):
	_customers.erase(customer)
	$Customers.remove_child(customer)
	customer.queue_free()
	_paths[path_id] = false
	
	if _customers.size() < 1:
		if $OpenTimer.is_stopped():
			return _set_state(State.AFTER)
		_spawn_customer()
		
	
		
##
# @method _spawn_puke
# @param {Vector3} trans
##
func _spawn_puke(trans:Vector3):
	if trans.x < 0:
		return
		
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
	# Score.
	if data.score != -999:
		if data.score > 0:
			_score.positive += data.score
		elif data.score < 0:
			_score.negative += abs(data.score)
		else:
			_score.neutral += 1
		
	# Streak.
	if data.score > 0:
		_streak += data.score
	else:
		if _streak > _score.streak:
			_score.streak = _streak
		_streak = 0
		
##
# @method _end
##
func _end():
	var total = 0
	for scores in _scores_by_stage:
		total += scores.positive
		total -= scores.negative
		total += scores.streak
		
	Session.register_score(total)
	
	get_tree().paused = false
	get_tree().change_scene("res://scenes/end/End.tscn")
