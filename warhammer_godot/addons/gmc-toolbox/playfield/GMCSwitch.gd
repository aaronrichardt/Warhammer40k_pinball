@tool

extends TextureButton
class_name GMCSwitch

@export var base_color := Color(1.0, 1.0, 1.0, 1.0)
@export var active_color := Color(0.0, 1.0, 0.0, 1.0)
@export var tags: Array
var server: Node
var texture_active: Texture
var texture_inactive: Texture
var _switch_state: bool = false
var _temp_toggle: bool = false

func _enter_tree():
    # Godot texture_pressed only responds to GUI, not internal state
    self.texture_inactive = preload("./icons/switch-inactive.svg")
    self.texture_active = preload("./icons/switch-active.svg")
    self.texture_pressed = self.texture_active
    self.stretch_mode = StretchMode.STRETCH_KEEP_ASPECT

func _ready():
    var parent = self.get_parent()
    while parent:
        if parent is MPFShowCreator:
            parent.register_switch(self)
            self.visible = false
            break
        elif parent is MPFMonitor:
            self.visible = true
            parent.register_switch(self)
            server = parent.server
            break
        parent = parent.get_parent()
    self.texture_normal = self.texture_inactive

func _gui_input(event):
    if not event is InputEventMouseButton:
        return
    # Ctrl+click to lock switch on, on press only (ignore unpress)
    if event.ctrl_pressed:
        if not event.pressed:
            return
        self._temp_toggle = true
    # Toggles only happen on mousedown
    if (self.toggle_mode or self._temp_toggle) and not event.pressed:
        # Use the unpress to remove the temporary toggle
        self._temp_toggle = false
        return

    var do_press = event.pressed
    # For toggle mode, invert the state
    if self.toggle_mode:
        do_press = not _switch_state
    # For a temporarily-toggled switch, turn it off
    elif self._temp_toggle and not event.ctrl_pressed:
        do_press = false
    # The server is the source of truth, let MPF set the switch
    # and post an event that will trigger the UI change
    if server:
        server.send_switch(self.name, 1 if do_press else 0)
    # If no server is connected, trigger the UI change
    else:
        self.set_switch_state(do_press)
    # Don't let the GUI buttons try and mess anything up
    get_tree().get_root().set_input_as_handled()

func set_switch_state(is_active: bool) -> void:
    if is_active:
        self.modulate = active_color
        self.texture_normal = self.texture_active
    else:
        self.modulate = base_color
        self.texture_normal = self.texture_inactive
    _switch_state = is_active
