extends MPFSlide

var ServerStatus = MPF.server.ServerStatus

# Called when the node enters the scene tree for the first time.
func _ready():
	var paths = [
		"CenterContainer/VBoxContainer/status_main",
		"CenterContainer/VBoxContainer/status_sub",
		"CenterContainer/VBoxContainer/error_main",
		"CenterContainer/VBoxContainer/error_sub",
	]
	for p in paths:
		var node = get_node_or_null(p)
		if node:
			node.hide()
	if MPF and MPF.server:
		MPF.server.status_changed.connect(self._on_status)
		# Call _on_status only if server has a status attribute
		if MPF.server.has_method("status") or MPF.server.has_meta("status"):
			self._on_status(MPF.server.status)

func _on_status(new_status):
	var error_node = get_node_or_null("CenterContainer/VBoxContainer/error_main")
	var status_node = get_node_or_null("CenterContainer/VBoxContainer/status_main")
	var target_child: Node = null
	var message: String = ""
	if new_status == ServerStatus.ERROR:
		target_child = error_node
		message = "Error: Unable to connect to MPF"
		if status_node:
			status_node.hide()
	else:
		target_child = status_node
		if error_node:
			error_node.hide()
		match new_status:
			ServerStatus.WAITING:
				message = "Waiting for MPF..."
			ServerStatus.LAUNCHING:
				message = "Launching MPF..."
			ServerStatus.CONNECTED:
				message = "Connected to MPF"
			ServerStatus.IDLE:
				message = ""
	if target_child:
		# Only set text/show if the node exists
		target_child.text = message
		target_child.show()
