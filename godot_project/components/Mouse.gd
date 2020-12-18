extends Spatial
class_name Mouse

const SPAWN_TIMES = [ 3, 15 ]

var _enabled:bool = false

##
# @override
##
func _ready():
	$MouseMesh.hide()
	
	$InteractableArea.connect("area_entered", self, "_on_player", [ false ])
	$InteractableArea.connect("area_exited", self, "_on_player", [ true ])
	
	$Timer.one_shot = true
	$Timer.start(Utils.irand_range(SPAWN_TIMES[0], SPAWN_TIMES[1]))
	$Timer.connect("timeout", self, "_spawn_mouse")
	
##
# @method reset
##
func reset():
	$InteractableArea/CollisionShape.disabled = true
	$MouseMesh.hide()
	
##
# @method set_enabled
# @param {bool} value
##
func set_enabled(value:bool):
	$InteractableArea/CollisionShape.disabled = true
	_enabled = value
	$Timer.paused = !value
	
##
# @method mouse_is_active
# @return {bool}
##
func mouse_is_active():
	return $AnimationPlayer.is_playing()

##
# @method _on_player
# @param {Player} player
# @param {bool} value
##
func _on_player(player, value:bool):
	if _enabled:
		$Timer.paused = !value
	
##
# @method _spawn_mouse
##
func _spawn_mouse():
	$MouseMesh.show()
	$AnimationPlayer.play("mouse")
	$InteractableArea/CollisionShape.disabled = false
	
##
# @method _on_mouse_finished
# @param {String} anim_name
##
func _on_mouse_finished(anim_name:String):
	$MouseMesh.hide()
	$AnimationPlayer.stop()
	$Timer.start(Utils.irand_range(SPAWN_TIMES[0], SPAWN_TIMES[1]))
	$InteractableArea/CollisionShape.disabled = true
