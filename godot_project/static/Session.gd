extends Node

var best_score:int = -1
var last_score:int = -1
var last_personal_best:bool = false

##
# @method register_score
# @param {int} score
# @return {bool}
##
func register_score(score:int):
	print("register_score " + str(score))
	last_score = score
	
	if score > best_score:
		best_score = score
		last_personal_best = true
		return true
		
	last_personal_best = false
	return false