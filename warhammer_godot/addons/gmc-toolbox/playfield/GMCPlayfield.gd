extends TextureRect
class_name GMCPlayfield

@export var animation_player: AnimationPlayer
@export var monitor_size: Vector2
var lights = {}
var switches = {}

func _enter_tree() -> void:
	var parent = self.get_parent()
	while parent:
		if parent is MPFMonitor:
			self.expand_mode = ExpandMode.EXPAND_IGNORE_SIZE
			break
		if parent is MPFShowCreator or parent is MPFShowPreview:
			self.expand_mode = ExpandMode.EXPAND_KEEP_SIZE
			break
		parent = parent.get_parent()
	# Prevent GMC from blocking inputs to allow switch presses
	# (if GMC is installed as an autoload in this project)
	if get_tree().get_root().get_node("MPF"):
		MPF.ignore_input()
