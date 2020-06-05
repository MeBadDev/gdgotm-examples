extends Node2D

const SCORE_TO_WIN = 10

var score_left = 0
var score_right = 0

signal game_finished()

onready var player2 = $Player2
onready var score_left_node = $ScoreLeft
onready var score_right_node = $ScoreRight
onready var winner_left = $WinnerLeft
onready var winner_right = $WinnerRight

func _ready():
	Gotm.connect("lobby_changed", self, "_on_gotm_lobby_changed")
	# By default, all nodes in server inherit from master,
	# while all nodes in clients inherit from puppet.
	# set_network_master is tree-recursive by default.
	if get_tree().is_network_server():
		# For the server, give control of player 2 to the other peer. 
		player2.set_network_master(get_tree().get_network_connected_peers()[0])
	else:
		# For the client, give control of player 2 to itself.
		player2.set_network_master(get_tree().get_network_unique_id())
	print("unique id: ", get_tree().get_network_unique_id())


sync func update_score(add_to_left):
	if add_to_left:
		score_left += 1
		score_left_node.set_text(str(score_left))
	else:
		score_right += 1
		score_right_node.set_text(str(score_right))
	
	var game_ended = false
	if score_left == SCORE_TO_WIN:
		winner_left.show()
		game_ended = true
	elif score_right == SCORE_TO_WIN:
		winner_right.show()
		game_ended = true
	
	if game_ended:
		$ExitGame.show()
		$Ball.rpc("stop")


func _on_gotm_lobby_changed():
	if not Gotm.lobby:
		_on_disconnect()

func _on_disconnect():
	$Player1.free()
	$Player2.free()
	get_tree().set_network_peer(null) # Remove peer.
	
	yield(get_tree(), "idle_frame")
	if Gotm.lobby:
		Gotm.lobby.leave()
		
	get_tree().change_scene("res://Menu.tscn")


func _on_exit_game_pressed():
	_on_disconnect()

