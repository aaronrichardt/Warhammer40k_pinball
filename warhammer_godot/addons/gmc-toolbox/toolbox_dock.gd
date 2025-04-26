@tool
extends Control

const CONFIG_PATH = "res://gmc_toolbox.cfg"
const DEFAULT_SHOW =  "res://show_creator.tscn"

var config: ConfigFile
var lights: = {}
var switches: = {}
var tags: = {}
var verbose: bool = false

@onready var button_mpf_lights_config = $MainVContainer/TopHContainer/LeftVContainer/container_mpf_lights_config/button_mpf_lights_config
@onready var edit_mpf_lights_config = $MainVContainer/TopHContainer/LeftVContainer/container_mpf_lights_config/edit_mpf_lights_config
@onready var button_mpf_switches_config = $MainVContainer/TopHContainer/LeftVContainer/container_mpf_switches_config/button_mpf_switches_config
@onready var edit_mpf_switches_config = $MainVContainer/TopHContainer/LeftVContainer/container_mpf_switches_config/edit_mpf_switches_config
@onready var button_playfield_scene = $MainVContainer/TopHContainer/LeftVContainer/container_playfield_scene/button_playfield_scene
@onready var edit_playfield_scene = $MainVContainer/TopHContainer/LeftVContainer/container_playfield_scene/edit_playfield_scene
@onready var button_launch_monitor = $MainVContainer/TopHContainer/RightVContainer/button_launch_monitor

@onready var button_generate_lights = $MainVContainer/TopHContainer/LeftVContainer/container_generators/button_generate_lights
@onready var button_generate_switches = $MainVContainer/TopHContainer/LeftVContainer/container_generators/button_generate_switches


func _ready():
	self.config = ConfigFile.new()
	var err = self.config.load(CONFIG_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		printerr("Error loading config file '%s': %s" % [CONFIG_PATH, error_string(err)])

	if self.config.has_section("show_creator"):
		for group in ["lights", "switches"]:
			if self.config.has_section_key("show_creator", "mpf_%s_config" % group):
				self["edit_mpf_%s_config" % group].text = self.config.get_value("show_creator", "mpf_%s_config" % group)
				if self["edit_mpf_%s_config" % group].text:
					debug_log("Found MPF %s config file '%s'" % [group, self["edit_mpf_%s_config" % group].text])
					self.parse_mpf_config(group)
		if self.config.has_section_key("show_creator", "playfield_scene"):
			var scene_path = self.config.get_value("show_creator", "playfield_scene")
			if FileAccess.file_exists(scene_path):
				edit_playfield_scene.text = scene_path
				debug_log("Found Playfield Scene '%s'" % edit_playfield_scene.text)
			else:
				self._save_playfield_scene("")

	# Set the listeners *after* the initial values are set
	button_mpf_lights_config.pressed.connect(Callable(self._select_mpf_config).bind("lights"))
	button_mpf_switches_config.pressed.connect(Callable(self._select_mpf_config).bind("switches"))
	button_playfield_scene.pressed.connect(self._select_playfield_scene)
	button_generate_lights.pressed.connect(self._generate.bind("lights"))
	button_generate_switches.pressed.connect(self._generate.bind("switches"))
	edit_mpf_lights_config.text_submitted.connect(self._save_mpf_config.bind("lights"))
	edit_mpf_switches_config.text_submitted.connect(self._save_mpf_config.bind("switches"))
	edit_playfield_scene.text_submitted.connect(self._save_playfield_scene)
	button_launch_monitor.pressed.connect(self._launch_monitor)

func _generate(group, parent_node: Control = null):
	if self[group].is_empty():
		printerr("No %s configuration found." % group)
		return
	var scene = load(edit_playfield_scene.text).instantiate()
	# Look for a lights child node
	if not parent_node:
		parent_node = scene.get_node_or_null(group)
	if not parent_node:
		parent_node = Control.new()
		parent_node.name = group
		parent_node.set_anchors_preset(LayoutPreset.PRESET_FULL_RECT)
		scene.add_child(parent_node)
		parent_node.owner = scene
	for i in self[group].keys():
		var item_child = scene.find_child(i)
		if not item_child:
			match group:
				"lights":
					item_child = GMCLight.new()
				"switches":
					item_child = GMCSwitch.new()
				_:
					printerr("Unknown item type '%s'" % group)
					return
			item_child.name = i
			if self.config.has_section_key(group, i):
				item_child.restore(self.config.get_value(group, i))
			else:
				item_child.global_position = Vector2(-1, -1)
			parent_node.add_child(item_child)
			item_child.owner = scene
		# Tags may have changed, so set that even on existing lights
		item_child.tags = self[group][i].tags

	debug_log("Added %s %s to the scene %s" % [parent_node.get_child_count(), group, edit_playfield_scene.text])
	var pckscene = PackedScene.new()
	var result = pckscene.pack(scene)
	if result != OK:
		push_error("Error packing scene: %s" % error_string(result))
		return
	var err = ResourceSaver.save(pckscene, edit_playfield_scene.text)
	if err != OK:
		push_error("Error saving scene: %s" % error_string(err))
		return

	EditorInterface.reload_scene_from_path(edit_playfield_scene.text)

func _launch_monitor():
	OS.create_process(OS.get_executable_path(), ["addons/gmc-toolbox/monitor/mpf_monitor.tscn"])

func _save_light_positions():
	EditorInterface.save_scene()
	var global_space = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height"))
	debug_log("Setting light positions on a %s x %s plane" % [global_space.x, global_space.y])

	var scene = load(edit_playfield_scene.text).instantiate()
	for l in self.lights.keys():
		var light = scene.find_child(l)
		debug_log("Checking light %s with node %s" % [l, light])
		if not light:
			push_warning("Light '%s' not found in scene" % l)
			continue
		if light.global_position == Vector2(-1, -1):
			debug_log("Light '%s' has not been positioned." % l)
			if self.config.has_section("lights") and self.config.has_section_key("lights", l):
				self.config.erase_section_key("lights", l)
			continue
		var settings = {
			"position": light.global_position / global_space,
			"shape": light.shape,
			"scale": light.scale,
			"rotation_degrees": light.rotation_degrees,
			"tags": self.lights[l]["tags"]
		}
		self.config.set_value("lights", l, settings)
	self.config.save(CONFIG_PATH)


func _generate_show():
	EditorInterface.play_custom_scene(edit_playfield_scene.text)

func _preview_show():
	EditorInterface.play_custom_scene("res://addons/gmc-toolbox/mpf_show_preview.tscn")

func _generate_scene():
	var root = MPFShowCreator.new()
	root.name = "MPFShowCreator"
	root.centered = false
	# Look for a playfield file
	for f in ["res://playfield.png", "res://playfield.jpg"]:
		if FileAccess.file_exists(f):
			root.texture = load(f)
	var animp = AnimationPlayer.new()
	animp.name = "AnimationPlayer"
	root.add_child(animp)
	root.animation_player = animp
	animp.owner = root
	var lights_node = Control.new()
	lights_node.name = "lights"
	root.add_child(lights_node)
	lights_node.owner = root

	var scene = PackedScene.new()
	var result = scene.pack(root)
	if result != OK:
		push_error("Error packing scene: %s" % error_string(result))
		return
	var err = ResourceSaver.save(scene, DEFAULT_SHOW)
	if err != OK:
		push_error("Error saving scene: %s" % error_string(err))
		return

	self.config.set_value("show_creator", "playfield_scene", DEFAULT_SHOW)
	self.config.save(CONFIG_PATH)
	edit_playfield_scene.text = DEFAULT_SHOW

	if not self.lights.is_empty():
		self._generate("lights")

	if DEFAULT_SHOW in EditorInterface.get_open_scenes():
		EditorInterface.reload_scene_from_path(DEFAULT_SHOW)
	else:
		EditorInterface.open_scene_from_path(DEFAULT_SHOW)


func _select_mpf_config(section: String):
	push_error("Select MPF config for %s" % section)
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	self.add_child(dialog)
	dialog.popup_centered(Vector2i(1100, 900))
	var path = await dialog.file_selected
	self._save_mpf_config(path, section)

func _save_mpf_config(path, section):
	self.config.set_value("show_creator", "mpf_%s_config" % section, path)
	self["edit_mpf_%s_config" % section].text = path
	self.config.save(CONFIG_PATH)
	if path:
		self.parse_mpf_config(section)

func _select_playfield_scene():
	var dialog = FileDialog.new()
	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	dialog.access = FileDialog.ACCESS_RESOURCES
	self.add_child(dialog)
	dialog.popup_centered(Vector2i(1100, 900))
	var path = await dialog.file_selected
	self._save_playfield_scene(path)

func _save_playfield_scene(path):
	self.config.set_value("show_creator", "playfield_scene", path)
	edit_playfield_scene.text = path
	self.config.save(CONFIG_PATH)

func _on_option(pressed, opt_name):
	self.config.set_value("show_creator", opt_name, pressed)
	self.config.save(CONFIG_PATH)
	if opt_name == "verbose":
		verbose = pressed

func parse_mpf_config(section_name: String):
	debug_log("Parsing MPF config at %s" % self["edit_mpf_%s_config" % section_name].text)
	var mpf_config = FileAccess.open(self["edit_mpf_%s_config" % section_name].text, FileAccess.READ)
	var line = mpf_config.get_line()
	var is_in_section = false
	var current_item: String
	var delimiter: String
	var delimiter_size: int
	while mpf_config.get_position() < mpf_config.get_length():
		var line_stripped = line.get_slice("#", 0).strip_edges()
		if not line_stripped:
			line = mpf_config.get_line()
			continue
		if line_stripped == "%s:" % section_name:
			debug_log(" - Found '%s:' section!" % section_name)
			is_in_section = true
			# The next line will give us our delimiter
			line = mpf_config.get_line()
			line_stripped = line.get_slice("#", 0).strip_edges()
			# ...unless the next line is blank or a comment
			while not line_stripped:
				line = mpf_config.get_line()
				line_stripped = line.get_slice("#", 0).strip_edges()
			var dedent = line.dedent()
			delimiter_size = line.length() - dedent.length()
			delimiter = line.substr(0, delimiter_size)

		if is_in_section:
			var line_data = line_stripped.split(":")
			var indent_check = line.substr(delimiter_size).length() - line.strip_edges(true, false).length()
			var collection = self[section_name]
			# If the check is zero, there is one delimiter and this is a new item
			if indent_check == 0:
				current_item = line_data[0]
				debug_log(" - Found a %s '%s'" % [section_name, current_item])
				collection[current_item] = { "tags": []}
			# If the check is larger, there is more than a delimiter and this is part of the item
			elif indent_check > 0:
				# Clear out any inline comments and extra whitespace
				if line_data[0] == "tags":
					debug_log("Trying to set tags on item %s" % collection[current_item])
					for t in line_data[1].split(","):
						var tag = t.strip_edges()
						if not self.tags.has(tag):
							self.tags[tag] = []
						self.tags[tag].append(current_item)
						collection[current_item]["tags"].append(tag)
			# If the check is smaller, there is less than a delimiter and we are done with this section
			else:
				is_in_section = false
		line = mpf_config.get_line()


func debug_log(message: String):
	if verbose:
		print_debug(message)
