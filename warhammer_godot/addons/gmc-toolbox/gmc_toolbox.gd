@tool
extends EditorPlugin

var show_creator_dock
var toolbox_dock

func _enter_tree():
	var version = Engine.get_version_info()
	if version.major < 4 or version.minor < 3:
		push_error("GMC Toolkit requires Godot version 4.3 or later, you have %s.%s.%s. Please visit godotengine.org to update." % [version.major, version.minor, version.patch])
		return
	add_custom_type("MPFShowCreator", "Sprite2D", preload("show_creator/MPFShowCreator.gd"), preload("icons/Camera2D.svg"))
	add_custom_type("GMCPlayfield", "TextureRect", preload("playfield/GMCPlayfield.gd"), preload("icons/Camera2D.svg"))
	add_custom_type("GMCLight", "Node2D", preload("playfield/GMCLight.gd"), preload("icons/DirectionalLight2D.svg"))
	add_custom_type("GMCSwitch", "TextureButton", preload("playfield/GMCSwitch.gd"), preload("icons/Button.svg"))
	toolbox_dock = preload("toolbox_dock.tscn").instantiate()
	add_control_to_bottom_panel(toolbox_dock, "GMC Toolbox")
	show_creator_dock = preload("show_creator_dock.tscn").instantiate()
	add_control_to_bottom_panel(show_creator_dock, "MPF Show Creator")

func _exit_tree():
	remove_custom_type("MPFShowCreator")
	remove_custom_type("GMCLight")
	remove_custom_type("GMCSwitch")
	remove_custom_type("GMCPlayfield")
	remove_control_from_bottom_panel(toolbox_dock)
	remove_control_from_bottom_panel(show_creator_dock)
