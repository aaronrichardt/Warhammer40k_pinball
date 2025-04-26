extends AspectRatioContainer
class_name MPFShowCreator

## The root node for creating light shows for MPF.

const CONFIG_PATH = "res://gmc_toolbox.cfg"

var _light_color: Color

## An AnimationPlayer node containing the animations to render as shows.
var animation_player: AnimationPlayer
## Color to modulate the light icons
@export var lights_color: Color = Color(0.3, 0.3, 0.3, 1.0):
	set(value):
		_light_color = value
		for l in lights:
			l.set_color(value)
	get:
		return _light_color

var lights = []
var switches = []
var spf: float
var file: FileAccess
var file_path: String
var tags := []

var config
var animation_name
var strip_unchanged_lights
var strip_empty_times
var use_alpha
var fps
var playfield_scene: Node
var show_yaml_path: String

var preview: Dictionary
var render_animation: bool = false

func _enter_tree():
	# Need to get the tags before ready state so we know whether to include lights
	config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err != OK and err != ERR_FILE_NOT_FOUND:
		printerr("Error loading config file '%s': %s" % [CONFIG_PATH, error_string(err)])
		return

	if not config.has_section("show_creator"):
		assert(false, "Config file has no show creator section")
		return

	var scene_path = config.get_value("show_creator", "show_scene")
	playfield_scene = load(scene_path).instantiate()
	self.add_child(playfield_scene)
	if self.name == "MPFShowCreator":
		render_animation = true
		show_yaml_path = config.get_value("show_creator", "show_yaml_path", false)
		assert(show_yaml_path, "Config missing show YAML path")
		assert(DirAccess.dir_exists_absolute(show_yaml_path), "Show YAML path %s does not exist" % show_yaml_path)
	if not render_animation:
		print("No render animaiton")
		return

	if config.has_section_key("show_creator", "animation"):
			animation_name = config.get_value("show_creator", "animation")

	fps = config.get_value("show_creator", "fps", 30)
	strip_unchanged_lights = config.get_value("show_creator", "strip_lights", true)
	strip_empty_times = config.get_value("show_creator", "strip_times", false)
	use_alpha = config.get_value("show_creator", "use_alpha", false)
	tags = config.get_value("tags", animation_name, [])

	var window = get_window()
	# self.size = playfield_scene.size
	window.size = playfield_scene.size
	window.content_scale_size = playfield_scene.size
	window.unresizable = true
	window.title = "MPF Show Creator - %s" % ProjectSettings.get_setting("application/config/name")
	window.transparent_bg = true
	print("Setting window size to: %s" % window.size)

	# Hide the playfield texture
	playfield_scene.texture = null

func _ready():
	set_process(false)

	if not render_animation:
		return

	assert(self.playfield_scene, "MPFShowCreator node requires a playfield scene as a texture.")
	assert(animation_name, "No animation name found in configuration.")
	animation_player = self.playfield_scene.animation_player
	assert(animation_player, "No AnimationPlayer node attached to the GMCPlayfield root.")
	assert(animation_player.has_animation(animation_name), "AnimationPlayer has no animation named '%s'" % animation_name)


	if not self.lights:
		if self.tags:
			assert(false, "No lights found matching the selected groups.")
		else:
			assert(false, "No lights found. Please add some GMCLight nodes.")

	self.spf = 1.0 / self.fps
	self.clip_children = CanvasItem.CLIP_CHILDREN_ONLY

	self.file_path = "%s/%s.yaml" % [show_yaml_path, animation_name]
	print("Looking for file path %s" % self.file_path)
	self.file = FileAccess.open(self.file_path, FileAccess.WRITE)
	self.file.store_line("#show_version=6")

	self.preview = { "show": animation_name, "timestamps": [], "light_steps": [] }

	await RenderingServer.frame_post_draw
	self.animation_player.assigned_animation = animation_name
	self.animation_player.callback_mode_process = AnimationPlayer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	self.animation_player.play(animation_name)
	self.animation_player.advance(0)
	self.animation_player.animation_finished.connect(self.on_animation_finished)

	# PAUSE
	self._run_animation()

func _run_animation():
	print("Generating animation show %s.yaml: duration %ss with frames every %0.5fs" % [self.animation_player.current_animation, self.animation_player.current_animation_length, self.spf])
	if self.tags:
		print("Show will include %s lights with tags: %s" % [self.lights.size(), ", ".join(self.tags)])
	else:
		print("Show will include all %s lights." % self.lights.size())
	var duration = self.animation_player.current_animation_length
	self.preview["duration"] = duration
	while self.animation_player.current_animation_position <= duration:
		await RenderingServer.frame_post_draw
		self.snapshot()
		self.animation_player.advance(self.spf)

func register_light(light: GMCLight):
	print("Light %s has position %s on scene size %s" % [light, light.position, self.playfield_scene.size])
	if light.position.x < 0 or light.position.y < 0 or light.position.x > self.playfield_scene.size.x or light.position.y > self.playfield_scene.size.y:
		# In the editor, include all lights
		if not Engine.is_editor_hint():
			push_warning("Light %s is outside of the viewport and will not be included." % light.name)
			return
	if self.tags and light.tags:
		var has_match = false
		for t in self.tags:
			if light.tags.find(t) != -1:
				has_match = true
				break
		if not has_match:
			return
	self.lights.append(light)

func register_switch(switch: GMCSwitch):
	if switch.position.x < 0 or switch.position.y < 0 or switch.position.x > self.playfield_scene.size.x or switch.position.y > self.playfield_scene.size.y:
		# In the editor, include all switchs
		if not Engine.is_editor_hint():
			push_warning("Switch %s is outside of the viewport and will not be included." % switch.name)
			return
	if self.tags and switch.tags:
		var has_match = false
		for t in self.tags:
			if switch.tags.find(t) != -1:
				has_match = true
				break
		if not has_match:
			return
	self.switches.append(switch)

func snapshot():
	var tex := get_window().get_texture().get_image()
	var timestamp = self.animation_player.current_animation_position
	var light_lines := []
	var preview_dict = {}
	for l in lights:
		var c = l.get_color(tex, strip_unchanged_lights)
		if c != null:
			light_lines.append("    %s: \"%s\"" % [l.name, c.to_html(use_alpha)])
			preview_dict[l.name] = c
	if light_lines or not strip_empty_times:
		file.store_line("- time: %0.5f" % timestamp)
		if light_lines:
			file.store_line("  lights:")
			for line in light_lines:
				file.store_line(line)
			# Only store preview on changes
			self.preview["timestamps"].append(timestamp)
			self.preview["light_steps"].append(preview_dict)

func on_animation_finished(_animation_name=null):
	self.finish()
	pass

func finish():
	set_process(false)
	file.close()
	for key in self.preview.keys():
		self.config.set_value("preview", key, self.preview[key])
	self.config.save(CONFIG_PATH)
	OS.shell_show_in_file_manager(self.file_path)
	get_tree().quit()
