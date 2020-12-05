extends Spatial
class_name CameraInstance

const LERP_SPEED = .1

var _target = null

##
# @override
##
func _ready():
	$Camera.translation = Vector3(0, 26, 26)
	$Camera.look_at(Vector3.ZERO, Vector3.UP);
	rotation.y = deg2rad(45)

##
# @override
##
func _physics_process(delta):
	if _target != null:
		translation = lerp(translation, _target.translation, LERP_SPEED)
		
##
# @method set_target
# @param {Variant} target
# @param {bool} tween
##
func set_target(target, tween:bool = false):
	_target = target
	if !tween:
		translation = _target.translation