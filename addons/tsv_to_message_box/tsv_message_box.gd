@tool
class_name MessageBox_TSV_Import extends CanvasLayer

signal open_message_box
signal close_message_box

@onready var messages_container: MarginContainer = %MarginContainer_Messages

@onready var button_next: Button = %Button_Next

var current_message_number: int = 0


var message_array: Array[String] = []

func _ready() -> void:		
	button_next.pressed.connect(_on_next_pressed)
	open_message_box.connect(_on_open_message_box)
	close_message_box.connect(_on_close_message_box)
	
	if messages_container.get_children():
		messages_container.get_child(0).visible = true
	
func _on_next_pressed() -> void:
	if current_message_number + 1 >= messages_container.get_children().size():
		close_message_box.emit()
	else:
		messages_container.get_child(current_message_number).visible = false
		current_message_number += 1
		messages_container.get_child(current_message_number).visible = true
	
func _on_open_message_box() -> void:
	self.visible = true
	
func _on_close_message_box() -> void:
	self.visible = false
	messages_container.get_child(current_message_number).visible = false
	current_message_number = 0
	messages_container.get_child(0).visible = true
