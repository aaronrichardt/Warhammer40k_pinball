extends MPFSlide

const ITEMS := ["khorne", "nurgle", "slannesh", "tzeench", "necrons", "backToTheFight"]
const INACTIVE_COLOR := Color(0.34, 0.36, 0.4, 0.62)
const ITEM_COLORS := {
	"khorne": Color(0.66, 0.16, 0.17, 1.0),
	"nurgle": Color(0.28, 0.46, 0.39, 1.0),
	"slannesh": Color(0.84, 0.22, 0.91, 1.0),
	"tzeench": Color(0.0, 0.4, 0.59, 1.0),
	"necrons": Color(0.51, 0.83, 0.12, 1.0),
	"backToTheFight": Color(0.4, 0.56, 0.82, 1.0)
}

@onready var selector: Control = $Selector

var selected_item := ""

func _ready() -> void:
	MPF.server.item_highlighted.connect(_on_item_highlighted)
	for item in ITEMS:
		_set_card_state(item, false, true)

func _exit_tree() -> void:
	if MPF.server.item_highlighted.is_connected(_on_item_highlighted):
		MPF.server.item_highlighted.disconnect(_on_item_highlighted)

func _on_item_highlighted(payload: Dictionary) -> void:
	if payload.get("carousel") != "mission_select":
		return
	var item := str(payload.get("item", ""))
	if item not in ITEMS:
		return
	selected_item = item
	for card_item in ITEMS:
		_set_card_state(card_item, card_item == selected_item)

func _set_card_state(item: String, active: bool, immediate := false) -> void:
	var card := selector.get_node_or_null(item)
	if card == null:
		return
	var panel := card.get_node("Panel") as ColorRect
	var label := card.get_node("Label") as Label
	var target_color: Color = ITEM_COLORS[item] if active else INACTIVE_COLOR
	var target_scale := Vector2(1.06, 1.06) if active else Vector2.ONE
	var target_modulate := Color(1, 1, 1, 1) if active else Color(0.55, 0.58, 0.64, 0.72)
	if immediate:
		panel.color = target_color
		card.scale = target_scale
		label.modulate = target_modulate
		return
	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "color", target_color, 0.18)
	tween.tween_property(card, "scale", target_scale, 0.18)
	tween.tween_property(label, "modulate", target_modulate, 0.18)
