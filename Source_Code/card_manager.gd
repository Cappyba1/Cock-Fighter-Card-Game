extends Node2D

const COLLSION_MASK_CARD = 1

var screen_size
var cards_being_dragged
var is_hovering_over_card

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size

# Clamp the position of the card to the screen size using delta

func _process(_delta):
	if cards_being_dragged:
		var mouse_pos = get_global_mouse_position()
		cards_being_dragged.position = Vector2(
			clamp(mouse_pos.x, 0, screen_size.x),
			clamp(mouse_pos.y, 0, screen_size.y)
		)
		cards_being_dragged.z_index = 1000

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_cards()
			if card:
				cards_being_dragged = card
		else:
			cards_being_dragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_over_card:highlight_card(card, true)

func on_hovered_off_card(card):
	highlight_card(card, false)


func highlight_card(card, hovered):
	if hovered:
		card.scale = Vector2(1.05, 1.05)
		card.z_index = 2
	else:
		card.scale = Vector2(1, 1)
		card.z_index = 1

# Ray cast to return whatever is under the cursor when it is clicked
func raycast_check_for_cards():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLSION_MASK_CARD
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		return result[0].collider.get_parent()
	return null
