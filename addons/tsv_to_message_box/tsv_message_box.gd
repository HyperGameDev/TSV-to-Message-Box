@tool

extends CanvasLayer

@onready var messages_container: MarginContainer = %MarginContainer_Messages

var messages_label := preload("res://addons/tsv_to_message_box/label_message_1.tscn").instantiate()

var message_array: Array[String] = []


func generate_messages() -> void:
	for message in message_array:
		messages_container.add_child(messages_label)
		messages_label.owner = owner
		messages_label.text = message
	
