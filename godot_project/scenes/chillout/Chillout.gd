extends Spatial

enum State {
	OPEN
}

const FIRST_SPAWN_TIME = 2
const SPAWN_TIMES = [ 5, 7, 9, 12 ]

onready var _customer_instance_resource = preload("res://components/CustomerInstance.tscn")

onready var _nodes = $Nodes.get_children()
onready var _paths;

var _state_id:int
var _customers:Array = []

##
# @override
##
func _ready():
	randomize()
	
	$Player.initialize($CameraControl/Camera)
	$CameraControl.set_target($CenterPoint)
	
	_paths = []
	for i in range(CustomerPath.data.size()):
		_paths.push_back(false)
	$Nodes.hide()
	
	$SpawnCostumerTimer.one_shot = true
	$SpawnCostumerTimer.connect("timeout", self, "_spawn_customer")
	
	_set_state(State.OPEN)
	MusicPlayer.play_track(MusicTrack.HAPPY_SONG)
	
##
# @method _set_state
# @param {int} state_id
##
func _set_state(state_id:int):
	_state_id = state_id
	
	match _state_id:
		State.OPEN:
			$SpawnCostumerTimer.start(FIRST_SPAWN_TIME)
			$Bar/Jukebox.activate(false)
	
##
# @override
##
func _physics_process(delta):
	if Input.is_action_just_released("ui_pause"):
		$PauseMenu.start()
		
##
# @method _spawn_customer
##
func _spawn_customer():
	$SpawnCostumerTimer.start(Utils.choose(SPAWN_TIMES))
		
	# Stop if no paths are available.
	if !_paths.has(false):
		return
		
	# Stop if max customers is reached.
	if _customers.size() >= 4:
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
	
	# Create customer.
	var customer_id = Utils.irand_range(0, Customer.data.size() - 1)
	var customer = _customer_instance_resource.instance()
	$Customers.add_child(customer)
	_customers.push_back(customer)
	customer.initialize(customer_id, nodes, $CameraControl/Camera, false)
	customer.set_chillout_mode(true)
	customer.connect("remove", self, "_on_customer_remove", [ customer, path_id ])
	FxPlayer.play(Fx.BELL, false)
	
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
