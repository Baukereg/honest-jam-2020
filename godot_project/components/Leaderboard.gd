extends Node2D

##
# @override
##
func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")

##
# @method get_scores
# @param {int} num
##
func get_scores(num:int = 5):
	$HTTPRequest.request(Constant.DREAMLO_GET_URL + str(num))

##
# @method submit_score
# @param {String} name
# @param {int} score
##
func submit_score(name:String, score:int):
	$HTTPRequest.request(Constant.DREAMLO_SUBMIT_URL + name + "/" + str(score))
	
##
# @method _on_request_completed
##
func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse(body.get_string_from_utf8())
	for entry in json.result.dreamlo.leaderboard.entry:
		var name_label:Label = Label.new()
		name_label.text = entry.name
		$VBoxContainer/Grid.add_child(name_label)

		var score_label:Label = Label.new()
		score_label.text = str(entry.score)
		$VBoxContainer/Grid.add_child(score_label)