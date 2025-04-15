extends Node2D

const COLLSION_MASK_CARD = 1

var screen_size
var cards_being_dragged
var is_hovering_on_card

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
				start_drag(card)
		else:
			stop_drag()


func start_drag(card):
	cards_being_dragged = card
	card.scale = Vector2(1.1, 1.1)

func stop_drag():
	if cards_being_dragged:
		cards_being_dragged.scale = Vector2(1.05, 1.05)
	cards_being_dragged = null


func connect_card_signals(card):
	card.connect("hovered", on_hovered_over_card)
	card.connect("hovered_off", on_hovered_off_card)

func on_hovered_over_card(card):
	if !is_hovering_on_card:
		is_hovering_on_card = true
		highlight_card(card, true)

func on_hovered_off_card(card):
	if !cards_being_dragged:
		# Check if hovered off card straight on to another card
		highlight_card(card, false)
		var new_card_hovered = raycast_check_for_cards()
		if new_card_hovered:
			highlight_card(new_card_hovered, true)
		else:
			is_hovering_on_card = false

func highlight_card(card, hovered):
	if card and card.has_method("set_scale") and card.has_method("set_z_index"):
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
		#return result[0].collider.get_parent()
		return get_card_with_highest_z_index(result)
	return null


func get_card_with_highest_z_index(cards):
	var highest_z_card = cards[0].collider.get_parent()
	var highest_z_index = highest_z_card.z_index

	for i in range(1, cards.size()):
		var card = cards[i].collider.get_parent()
		if card.z_index > highest_z_index:
			highest_z_card = card
			highest_z_index = card.z_index
	return highest_z_card
