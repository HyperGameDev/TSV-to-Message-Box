@tool
extends EditorPlugin

var main_plugin := preload("res://addons/tsv_to_message_box/main_plugin.tscn").instantiate()

var _file_dialog: FileDialog = FileDialog.new()

var skip_top_row: bool = true

var lines_to_generate: int

var message_array: Array[String] = []
var signal_array: Array[String] = []

func _enter_tree() -> void:
	add_control_to_bottom_panel(main_plugin,"TSV to Msg Box")
	
	create_file_dialog()
	
	scene_changed.connect(_on_scene_changed)
	
	main_plugin.button_upload.pressed.connect(_on_upload_pressed)
	main_plugin.button_generate.pressed.connect(_on_generate_pressed)

func create_file_dialog() -> void:
	var base_control : Panel = EditorInterface.get_base_control()
	
	_file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	_file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	_file_dialog.filters = PackedStringArray(["*.tsv"])
	_file_dialog.connect("file_selected",_on_file_selected)
	
	base_control.add_child(_file_dialog)
	
func _on_upload_pressed() -> void:
	_file_dialog.show()
	_file_dialog.popup_centered_ratio(.5)

func _on_file_selected(path) -> void:
	_file_dialog.hide()
	
	clear_previous_tsv_data()
	
	var tsv_file_path: String = path
	main_plugin.file_name.text = tsv_file_path
	
	load_tsv(tsv_file_path)
	
func clear_previous_tsv_data() -> void:
	var tsv_table_rows: Array[Node] = main_plugin.vbox_tsv_table.get_children()
	for row in tsv_table_rows:
		if row.name == "Row0":
			continue
		row.queue_free()

func load_tsv(path) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var tsv_data: String = file.get_as_text()
	
	parse_tsv(tsv_data)
	
func parse_tsv(data) -> void:
	var lines: PackedStringArray = data.split("\n")
	
	for line in lines:
		var line_data: PackedStringArray = line.split("\t")
		
		var message_string: String = line_data[0]
		message_array.append(message_string.substr(0,100))
		
		var signal_string: String = line_data[1] 
		signal_array.append(signal_string)
		
	lines_to_generate = lines.size()
	if lines_to_generate > 0:
		generate_preview()

func generate_preview() -> void:
	generate_table_preview()
	show_tsv_to_generate()
	
func generate_table_preview() -> void:
	var tsv_table: VBoxContainer = main_plugin.vbox_tsv_table
	
	for i in lines_to_generate:
		if skip_top_row:
			if i < 1:
				continue
		var tsv_row := preload("res://addons/tsv_to_message_box/row.tscn").instantiate()
		tsv_table.add_child(tsv_row)
		tsv_row.get_node("%Label_Message").text = message_array[i]
		tsv_row.get_node("%Label_Signal").text = signal_array[i]
		
func _on_scene_changed(scene: Node):	
	if scene == null:
		scene_empty_error(true,scene)
	else:
		scene_empty_error(false,scene)
		
func scene_empty_error(is_empty: bool,scene: Node) -> void:
	var generate_button: Button = main_plugin.button_generate
	
	if is_empty:
		generate_button.disabled = true
		generate_button.text = "[SCENE IS EMPTY]"
	else:
		generate_button.disabled = false
		generate_button.text = "Generate (in " + str(scene.name) + ")"
	
func show_tsv_to_generate() -> void:
	var tsv_preview: PanelContainer = main_plugin.tsv_preview
	var generate_button: Button = main_plugin.button_generate
	var scene_currently_highlited := get_editor_interface().get_edited_scene_root()
	
	tsv_preview.visible = true
	
	_on_scene_changed(scene_currently_highlited)
	generate_button.visible = true
	
func _on_generate_pressed() -> void:
	var scene_currently_highlited := get_editor_interface().get_edited_scene_root()
	var hbox_error: HBoxContainer = main_plugin.hbox_error
	
	main_plugin.button_generate.disabled = true
	
	if msg_box_exists(scene_currently_highlited):
		create_message_box(scene_currently_highlited,hbox_error)
	else:
		hbox_error.visible = true
		
		var label_error_msg: Label = main_plugin.label_error_msg
		label_error_msg.text = "A message box already exists!"
		
func msg_box_exists(scene_currently_highlited) -> bool:
	var add_a_box: bool = true

	for node in scene_currently_highlited.get_children():
		if node is MessageBox_TSV_Import:
			add_a_box = false
			
			break
	
	return add_a_box

func create_message_box(scene_currently_highlited,hbox_error) -> void:
	hbox_error.visible = false # If there is an error, get rid of it
	
	duplicated_msg_box_instance(scene_currently_highlited)		

func duplicated_msg_box_instance(scene_currently_highlited) -> void:
	var msg_box_to_instantiate: CanvasLayer = preload("res://addons/tsv_to_message_box/tsv_message_box.tscn").instantiate()
	
	var msg_box_instance: CanvasLayer
	
	if scene_currently_highlited:
		scene_empty_error(false,scene_currently_highlited)
		scene_currently_highlited.add_child(msg_box_to_instantiate)
	else:
		scene_empty_error(true,scene_currently_highlited)
		
	for node in scene_currently_highlited.get_children():
		if node is MessageBox_TSV_Import:
			msg_box_instance = node
			break
			
	var message_box: CanvasLayer = msg_box_instance.duplicate()
	
	msg_box_instance.queue_free()
	
	add_message_box_to_scene(message_box,scene_currently_highlited)
	
func add_message_box_to_scene(message_box,scene_currently_highlited) -> void:
	if scene_currently_highlited:
		scene_empty_error(false,scene_currently_highlited)
		scene_currently_highlited.add_child(message_box)
		generate_messages(scene_currently_highlited,message_box)
	else:
		scene_empty_error(true,scene_currently_highlited)
			
func generate_messages(scene_currently_highlited,box_to_add_messages_to) -> void:
	var messages_container: MarginContainer = box_to_add_messages_to.messages_container
	
	for i in range(message_array.size()):
		if skip_top_row and i == 0:
			continue
	
		var message = message_array[i]
		var messages_label := preload("res://addons/tsv_to_message_box/label_message_1.tscn").instantiate()
		messages_container.add_child(messages_label)
		messages_label.owner = scene_currently_highlited
		messages_label.text = message

	messages_container.get_child(0).visible = true
	add_box_to_edited_scene(scene_currently_highlited,box_to_add_messages_to)
	
	
func add_box_to_edited_scene(scene_with_messages,message_box_to_add):
	message_box_to_add.owner = scene_with_messages
	
	main_plugin.button_generate.disabled = false
	

func _exit_tree() -> void:
	remove_control_from_bottom_panel(main_plugin)
	main_plugin.queue_free()
