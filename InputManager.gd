extends Node2D

signal left_mouse_button_clicked
signal left_mouse_button_released

const COLLISION_MASK_CARD = 1
const COLLISION_MASK_DECK = 4 # Layer 3 no inspetor = valor 4 no código (2^2)

var card_manager_reference
var deck_reference

func _ready():
	card_manager_reference = $"../CardManager"
	deck_reference = $"../Deck" # Criaremos esse nó no próximo passo

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			emit_signal("left_mouse_button_clicked")
			raycast_at_cursor()
		else:
			emit_signal("left_mouse_button_released")

func raycast_at_cursor():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	
	var result = space_state.intersect_point(parameters)
	if result.size() > 0:
		var result_collision_layer = result[0].collider.collision_layer
		print("InputManager.raycast_at_cursor: hit layer=", result_collision_layer)
		
		# Se clicou numa CARTA (use bitwise check em vez de igualdade)
		if (result_collision_layer & COLLISION_MASK_CARD) != 0:
			var card_found = result[0].collider.get_parent()
			# Ensure the found node is actually a card (in group 'card') before starting drag
			if card_found and card_found.is_in_group("card") and card_manager_reference:
				# Use call_deferred para evitar problemas de ordem de execução
				card_manager_reference.call_deferred("start_drag", card_found)
		
		# Se clicou no DECK
		elif (result_collision_layer & COLLISION_MASK_DECK) != 0:
			if deck_reference:
				deck_reference.call_deferred("draw_card")
