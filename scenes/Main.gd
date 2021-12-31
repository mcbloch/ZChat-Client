extends Node2D

var chatboxPre : PackedScene = preload("res://scenes/ChatBox.tscn")

func _on_Button_pressed():
	var lineedit = $Viewport/MarginContainer/VBoxContainer/HBoxContainer2/LineEdit
	$Networking.send_data(lineedit.text)
	lineedit.text = ""


func _on_Networking_received_chat_message(message):
	var chatbox = chatboxPre.instance()
	chatbox.get_node("Label").text = message
	chatbox.fix_size()
	$Chats.add_child(chatbox)
	$Node2D/Particles2D.restart()
	$Node2D/Particles2D.one_shot = true


func _on_Reconnect_pressed():
	$Networking.reconnect()
