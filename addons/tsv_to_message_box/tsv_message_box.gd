@tool

class_name MessageBox_TSV_Import extends CanvasLayer

@onready var messages_container: MarginContainer = %MarginContainer_Messages


var message_array: Array[String] = []


func generate_messages() -> void:
	for message in message_array:
		var messages_label := preload("res://addons/tsv_to_message_box/label_message_1.tscn").instantiate()
		messages_container.add_child(messages_label)
		messages_label.owner = owner
		messages_label.text = message
	
