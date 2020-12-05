extends Spatial

onready var _customer_instance_resource = preload("res://components/CustomerInstance.tscn")

onready var _nodes = $Nodes.get_children()
onready var _paths;

##
# @override
##
func _ready():
	randomize()
	
	$Player.initialize($CameraControl/Camera)
	$CameraControl.target = $Player
	
	_paths = []
	for i in range(CustomerPath.data.size()):
		_paths.push_back(false)
	$Nodes.hide()
	
	$SpawnCostumerTimer.wait_time = 2
	$SpawnCostumerTimer.start()
	$SpawnCostumerTimer.connect("timeout", self, "spawn_customer")
	
##
# @override
##
func _physics_process(delta):
	if Input.is_action_just_released("ui_pause"):
		$PauseMenu.start()
		
##
# @method spawn_customer
##
func spawn_customer():
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
	add_child(customer)
	customer.initialize(customer_id, nodes, $CameraControl/Camera)
	customer.connect("removed", self, "free_path", [ path_id ])
	
##
# @method free_path
# @param {int} path_id
##
func free_path(path_id):
	_paths[path_id] = false
	