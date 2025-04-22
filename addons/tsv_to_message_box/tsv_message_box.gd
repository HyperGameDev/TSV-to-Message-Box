@tool

class_name MessageBox_TSV_Import extends CanvasLayer

@onready var messages_container: MarginContainer = %MarginContainer_Messages

@onready var button_next: Button = %Button_Next

var current_message_number: int = 0


var message_array: Array[String] = []

func _ready() -> void:
	
	if not get_parent().is_editable_instance(self):
		get_parent().set_editable_instance(self,true)
		
	button_next.pressed.connect(_on_next_pressed)
	
	if messages_container.get_children().size() > 0:
		messages_container.get_child(0).visible = true
	
func _on_next_pressed():
	messages_container.get_child(current_message_number).visible = false
	current_message_number += 1
	messages_container.get_child(current_message_number).visible = true
	
	
