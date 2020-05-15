extends Node2D

const SERVER_PORT = 7070
const SERVER_IP   = "127.0.0.1"
const MAX_PLAYERS = 1000

var peer
var players = {}
var self_id = 0

var RemotePlayer = load("res://Components/RemotePlayer/RemotePlayer.tscn")

func _ready():
	peer = NetworkedMultiplayerENet.new()
	# CLIENT & SERVER ######################
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	# CLIENT ONLY ###########################
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")
	
func start_client():
	$CanvasLayer/Control/Label.text = ""
	addlog("---- CLIENT ----")
	$CanvasLayer/Control/ServerStart.hide()
	$CanvasLayer/Control/ClientStart.hide()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)

func start_server():
	$CanvasLayer/Control/Label.text = ""
	$CanvasLayer/Control/ServerStart.hide()
	$CanvasLayer/Control/ClientStart.hide()
	addlog("---- SERVER ----")
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().set_network_peer(peer)
	

func _player_connected(id):
	addlog("\n[INFO] Player connected:" + str(id))
	var player = RemotePlayer.instance()
	player.name = "pl_" + str(id)
	player.position = Vector2(randi() % 500 - 250, randi() % 500 - 250)
	$Players.add_child(player)
	
remote func update_remote_player_position(id, pos):
	if id != self_id:
		var player = $Players.get_node("pl_" + str(id))
		if player:
			player.target_position = pos
	
func distribute_position(new_pos):
	rpc_unreliable("update_remote_player_position", get_tree().get_network_unique_id(), new_pos)
	
remote func register_player(id, info):
	players[id] = info
	addlog("Player " + str(id) + " has name: " + info["nick"])
	if get_tree().is_network_server():
		rpc_id(id, "register_player", 1, { "nick": "Server" })
		for peer_id in players:
			rpc_id(id, "register_player", peer_id, players[peer_id])
	
	
## CLIENT PART ##########################
func _connected_ok():
	self_id = get_tree().get_network_unique_id()
	addlog("\n[ME] I am connected to server")
	rpc("register_player", get_tree().get_network_unique_id(), { "nick": $CanvasLayer/Control/TextEdit.text } )
	
	
func addlog(text):
	$CanvasLayer/Control/Label.text = $CanvasLayer/Control/Label.text + text








