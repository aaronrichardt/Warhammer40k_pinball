@tool
extends Control

const CONFIG_PATH = "res://gmc_toolbox.cfg"
const DEFAULT_SHOW =  "res://show_creator.tscn"

var config: ConfigFile
var lights: = {}
var switches: = {}
var tags: = {}
var verbose: bool = true

@onready var edit_fps = $MainVContainer/TopHContainer/LeftVContainer/BottomFContainer/container_fps/edit_fps
@onready var button_strip_lights = $MainVContainer/TopHContainer/LeftVContainer/BottomFContainer/button_strip_lights
@onready var button_strip_times = $MainVContainer/TopHContainer/LeftVContainer/BottomFContainer/button_strip_times
@onready var button_use_alpha = $MainVContainer/TopHContainer/LeftVContainer/BottomFContainer/button_use_alpha
@onready var button_verbose = $MainVContainer/TopHContainer/LeftVContainer/BottomFContainer/button_verbose

@onready var button_refresh_animations = $MainVContainer/TopHContainer/LeftVContainer/container_generators/button_refresh_animations

@onready var tags_container = $MainVContainer/TopHContainer/CenterVContainer/ScrollContainer/tag_checks
@onready var button_tags_select_all = $MainVContainer/TopHContainer/CenterVContainer/TagsHContainer/button_tags_select_all
@onready var button_tags_deselect_all = $MainVContainer/TopHContainer/CenterVContainer/TagsHContainer/button_tags_deselect_all

@onready var animation_dropdown = $MainVContainer/TopHContainer/RightVContainer/button_animation_names
@onready var button_show_maker = $MainVContainer/TopHContainer/RightVContainer/button_generate_show
@onready var button_preview_show = $MainVContainer/TopHContainer/RightVContainer/button_preview_show

func _ready():
	self.config = ConfigFile.new()
	var err = self.config.load(CONFIG_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		printerr("Error loading config file '%s': %s" % [CONFIG_PATH, error_string(err)])

	if self.config.has_section("show_creator"):
		if self.config.has_section_key("show_creator", "verbose"):
			button_verbose.button_pressed = self.config.get_value("show_creator", "verbose")
			verbose = button_verbose.button_pressed
		if self._get_playfield_scene():
			self._get_animation_names()
		if self.config.has_section_key("show_creator", "strip_lights"):
			button_strip_lights.button_pressed = self.config.get_value("show_creator", "strip_lights", true)
		if self.config.has_section_key("show_creator", "strip_times"):
			button_strip_times.button_pressed = self.config.get_value("show_creator", "strip_times", true)
		if self.config.has_section_key("show_creator", "use_alpha"):
			button_use_alpha.button_pressed = self.config.get_value("show_creator", "use_alpha", false)

	# Set the listeners *after* the initial values are set
	button_show_maker.pressed.connect(self._generate_show)
	button_preview_show.pressed.connect(self._preview_show)
	animation_dropdown.item_selected.connect(self._select_animation)
	button_refresh_animations.pressed.connect(self._get_animation_names)

	# Tags
	button_tags_select_all.pressed.connect(self._select_all_tags)
	button_tags_deselect_all.pressed.connect(self._deselect_all_tags)

	# Configuration buttons
	button_strip_lights.toggled.connect(self._on_option.bind("strip_lights"))
	button_strip_times.toggled.connect(self._on_option.bind("strip_times"))
	button_use_alpha.toggled.connect(self._on_option.bind("use_alpha"))
	button_verbose.toggled.connect(self._on_option.bind("verbose"))

	button_show_maker.disabled = animation_dropdown.item_count == 0

# func _save_light_positions():
# 	EditorInterface.save_scene()
# 	var global_space = Vector2(
# 		ProjectSettings.get_setting("display/window/size/viewport_width"),
# 		ProjectSettings.get_setting("display/window/size/viewport_height"))
# 	debug_log("Setting light positions on a %s x %s plane" % [global_space.x, global_space.y])

# 	var scene = load(edit_show_scene.text).instantiate()
# 	for l in self.lights.keys():
# 		var light = scene.find_child(l)
# 		debug_log("Checking light %s with node %s" % [l, light])
# 		if not light:
# 			push_warning("Light '%s' not found in scene" % l)
# 			continue
# 		if light.global_position == Vector2(-1, -1):
# 			debug_log("Light '%s' has not been positioned." % l)
# 			if self.config.has_section("lights") and self.config.has_section_key("lights", l):
# 				self.config.erase_section_key("lights", l)
# 			continue
# 		var settings = {
# 			"position": light.global_position / global_space,
# 			"shape": light.shape,
# 			"scale": light.scale,
# 			"rotation_degrees": light.rotation_degrees,
# 			"tags": self.lights[l]["tags"]
# 		}
# 		self.config.set_value("lights", l, settings)
# 	self.config.save(CONFIG_PATH)


func _generate_show():
	EditorInterface.play_custom_scene("res://addons/gmc-toolbox/show_creator/mpf_show_creator.tscn")

func _preview_show():
	EditorInterface.play_custom_scene("res://addons/gmc-toolbox/show_creator/mpf_show_preview.tscn")

func _get_animation_names():
	EditorInterface.save_scene()
	animation_dropdown.clear()
	var playfield_scene = self._get_playfield_scene()
	print("Got playfield scene: %s" % playfield_scene)
	if not playfield_scene.animation_player:
		debug_log("No animation player attached to scene, animations unavailable.")
		return
	var animp = playfield_scene.animation_player
	var animations = animp.get_animation_list()
	print(" - found animations:")
	print(animations)
	if animations.has("RESET"):
		animations.remove_at(animations.find("RESET"))

	var selected_index = -1
	if self.config.has_section_key("show_creator", "animation") and self.config.get_value("show_creator", "animation", false):
		selected_index = animations.find(self.config.get_value("show_creator", "animation"))

	for a in animations:
		animation_dropdown.add_item(a)
	if selected_index != -1 and selected_index < animation_dropdown.item_count:
		animation_dropdown.select(selected_index)
		self._select_animation(selected_index)
	# If no selected index then none has been saved, so trigger a save
	elif animation_dropdown.item_count:
		self._select_animation(0)
	debug_log("Found %s animations: %s" % [animation_dropdown.item_count, animations])
	button_show_maker.disabled = animation_dropdown.item_count == 0

func _select_animation(idx: int):
	var animation_name = animation_dropdown.get_item_text(idx)

	# Update the tags list based on this animation
	if self.config.has_section_key("tags", animation_name):
		var include_tags = self.config.get_value("tags", animation_name)
		for tag_box in tags_container.get_children():
			tag_box.button_pressed = tag_box.text in include_tags
	else:
		self._select_all_tags()

	# If this is already the saved animation, no more to do
	if self.config.has_section_key("show_creator", "animation") and animation_name == self.config.get_value("show_creator", "animation"):
		return

	self.config.set_value("show_creator", "animation", animation_name)
	self.config.save(CONFIG_PATH)

func _select_all_tags():
	for tag_box in tags_container.get_children():
		tag_box.button_pressed = true
	self._save_tags()

func _deselect_all_tags():
	for tag_box in tags_container.get_children():
		tag_box.button_pressed = false
	self._save_tags()

func _save_tags(_toggle_state=false):
	# Check for tags to attach to this show
	var animation_name = animation_dropdown.get_item_text(animation_dropdown.selected)
	var included_tags = []
	var excluded_tags = []
	for tag in tags_container.get_children():
		if tag.button_pressed:
			included_tags.append(tag.text)
		else:
			excluded_tags.append(tag.text)
	# If any tags are excluded, store the included ones
	if excluded_tags:
		self.config.set_value("tags", animation_name, included_tags)
	elif self.config.has_section_key("tags", animation_name):
		self.config.erase_section_key("tags", animation_name)
	self.config.save(CONFIG_PATH)

# func _select_show_scene():
# 	var dialog = FileDialog.new()
# 	dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
# 	dialog.access = FileDialog.ACCESS_RESOURCES
# 	self.add_child(dialog)
# 	dialog.popup_centered(Vector2i(1100, 900))
# 	var path = await dialog.file_selected
# 	self._save_show_scene(path)


func _on_option(pressed, opt_name):
	self.config.set_value("show_creator", opt_name, pressed)
	self.config.save(CONFIG_PATH)
	if opt_name == "verbose":
		verbose = pressed

func _get_playfield_scene():
	if not self.config.has_section("show_creator") or not self.config.get_value("show_creator", "playfield_scene"):
		debug_log("No playfield scene configured in GMC Toolbox.")
		return
	var scene_path = self.config.get_value("show_creator", "playfield_scene")
	if not FileAccess.file_exists(scene_path):
		debug_log("Playfield scene '%s' file not found" % scene_path)
		return
	var scene = load(scene_path).instantiate()
	return scene

func debug_log(message: String):
	if verbose:
		print_debug(message)
