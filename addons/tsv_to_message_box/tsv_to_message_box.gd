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

func show_tsv_to_generate() -> void:
	var tsv_preview: PanelContainer = main_plugin.tsv_preview
	var generate_button: Button = main_plugin.button_generate
	
	tsv_preview.visible = true
	generate_button.visible = true
	
func _on_generate_pressed() -> void:
	var message_box := preload("res://addons/tsv_to_message_box/tsv_message_box.tscn").instantiate()
	var scene_being_edited := get_editor_interface().get_edited_scene_root()
	if scene_being_edited:
		scene_being_edited.add_child(message_box)
		add_box_to_edited_scene(scene_being_edited,message_box)
		transfer_messages(message_box)
		
func transfer_messages(message_box) -> void:
	for i in lines_to_generate:
		if skip_top_row:
			if i < 1:
				continue
		message_box.message_array.append(message_array[i])
		
	message_box.generate_messages()
	
func add_box_to_edited_scene(scene_with_messages,message_box_to_add):
	message_box_to_add.owner = scene_with_messages
	

func _exit_tree() -> void:
	remove_control_from_bottom_panel(main_plugin)
	main_plugin.queue_free()
