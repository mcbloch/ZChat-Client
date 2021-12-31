extends Node

signal received_chat_message

#onready var _log_dest = get_parent().get_node("Panel/VBoxContainer/RichTextLabel")

# The URL we will connect to
export var websocket_url = "ws://192.168.0.205:8000/chat"
var _write_mode = WebSocketPeer.WRITE_MODE_TEXT

# Our WebSocketClient instance
var _client = WebSocketClient.new()

func _ready():
	# Connect base signals to get notified of connection open, close, and errors.
	_client.connect("connection_established", self, "_client_connected")
	_client.connect("connection_error", self, "_client_disconnected")
	_client.connect("connection_closed", self, "_client_disconnected")
	_client.connect("server_close_request", self, "_client_close_request")
	# This signal is emitted when not using the Multiplayer API every time
	# a full packet is received.
	# Alternatively, you could check get_peer(1).get_available_packets() in a loop.
	_client.connect("data_received", self, "_client_data_received")

	_client.connect("peer_packet", self, "_client_received")
	_client.connect("peer_connected", self, "_peer_connected")
	_client.connect("connection_succeeded", self, "_client_connected", ["multiplayer_protocol"])
	_client.connect("connection_failed", self, "_client_disconnected")

	# Initiate connection to the given URL.
	reconnect()

func _client_close_request(code, reason):
	print("Close code: %d, reason: %s" % [code, reason])

# TODO Remove?
func _peer_connected(id):
	print("%s: Client just connected" % [id])
	
func _exit_tree():
	_client.disconnect_from_host(1001, "Bye bye!")

func _process(_delta):
	get_parent().get_node("Viewport/MarginContainer/VBoxContainer/HBoxContainer3/Label").text = ["DISCONNECTED", "CONNECTING", "CONNECTED"][_client.get_connection_status()]
	if _client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		return

	# Call this in _process or _physics_process. Data transfer, and signals
	# emission will only happen when calling this function.
	_client.poll()

func _client_connected(protocol = ""):
	# This is called on connection, "proto" will be the selected WebSocket
	# sub-protocol (which is optional)
	print("Client just connected with protocol: %s" % protocol)
	# You MUST always use get_peer(1).put_packet to send data to server,
	# and not put_packet directly when not using the MultiplayerAPI.
	send_data("Test packet")

func _client_disconnected(clean = false):
	# was_clean will tell you if the disconnection was correctly notified
	# by the remote peer before closing the socket.
	print("Client just disconnected. Was clean: %s" % clean)
	_client.disconnect_from_host(1001, "Bye bye!")


func _client_data_received():
	# Print the received packet, you MUST always use get_peer(1).get_packet
	# to receive data from server, and not get_packet directly when not
	# using the MultiplayerAPI.
	var packet = _client.get_peer(1).get_packet()
	var is_string = _client.get_peer(1).was_string_packet()
	print("Received data. String: %s: %s" % [not is_string, packet.get_string_from_utf8()])
	emit_signal("received_chat_message", packet.get_string_from_utf8())
	
func reconnect():
	if _client.get_connection_status() == WebSocketClient.CONNECTION_DISCONNECTED:
		var err = _client.connect_to_url(websocket_url)
		if err != OK:
			print("Unable to connect")
			set_process(false)
		else:
			print("Connected...")
	else:
		print("Did not try to reconnect: already connected")
	
func send_data(data):
	_client.get_peer(1).set_write_mode(_write_mode)
	_client.get_peer(1).put_packet(data.to_utf8())
