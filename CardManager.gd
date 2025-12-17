extends Node2D

const COLLISSION_MASK_CARD = 1
const COLLISSION_MASK_CARD_SLOT = 2

var screen_size: Vector2
var card_being_dragged = null
var card_hovered = null
var card_target_slot = null # slot candidate durante o drag
var played_monster_this_turn: bool = false

@onready var input_manager = $"../InputManager"
@onready var player_hand = $"../PlayerHand"


func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	# Conecta o sinal de release do InputManager
	if input_manager:
		input_manager.connect("left_mouse_button_released", Callable(self, "on_left_click_released"))
	# Atualiza screen_size quando a janela mudar de tamanho
	var vp = get_viewport()
	if vp:
		vp.connect("size_changed", Callable(self, "_on_viewport_size_changed"))


func _process(delta):
	# -------------------------------------------------
	# DRAG-AND-DROP
	# -------------------------------------------------
	if card_being_dragged:
		# Pass the dragged card as an exception so the raycast can see the slot behind it
		var card_slot_found = raycast_check_for_card_slot(card_being_dragged)
		var mouse_pos = get_global_mouse_position()
		var vs = get_viewport().get_visible_rect().size
		var new_pos = Vector2(
			clamp(mouse_pos.x, 0, vs.x),
			clamp(mouse_pos.y, 0, vs.y)
		)
		# movimenta livremente com o mouse
		card_being_dragged.global_position = new_pos

		# se houver um slot válido, mostra snap visual mas NÃO confirma/disable collider ainda
		if card_slot_found and card_slot_found.card_in_slot == null:
			card_target_slot = card_slot_found
			# snap visual para o centro do slot
			card_being_dragged.global_position = card_target_slot.global_position
		else:
			card_target_slot = null

		# Bloqueia hover durante drag
		_hide_card_preview()
		return

	# -------------------------------------------------
	# HOVER CHECK
	# -------------------------------------------------
	var hit_card = raycast_check_for_card()

	if hit_card != card_hovered:
		# Se tinha uma carta hoverada anteriormente, desativa
		if card_hovered:
			highlight_card(card_hovered, false)
			_hide_card_preview()

		# Atualiza carta atual
		card_hovered = hit_card

		# Se agora existe uma nova carta hoverada
		if card_hovered:
			highlight_card(card_hovered, true)
			_show_card_preview(card_hovered)


# NOVAS FUNÇÕES: input delegations
func start_drag(card):
	if not card:
		return
	# Ensure this is a card node
	if not card.is_in_group("card"):
		return
	# Se a carta está presa no slot, não permita pegar
	if card.locked_in_slot:
		return
	# Garante collider ativo
	var shape = card.get_node_or_null("Area2D/CollisionShape2D")
	if shape:
		shape.disabled = false
	card_being_dragged = card

func on_left_click_released():
	if card_being_dragged:
		finish_drag()

func finish_drag():
	if not card_being_dragged:
		return

	# Re-check slot under mouse, ignorando a carta sendo arrastada
	var slot_encontrado = raycast_check_for_card_slot(card_being_dragged)

	if slot_encontrado and slot_encontrado.card_in_slot == null:
		# Remover da mão e colocar no slot
		if player_hand:
			player_hand.remove_card_from_hand(card_being_dragged)
		if slot_encontrado.has_method("accept_card"):
			slot_encontrado.accept_card(card_being_dragged)
		else:
			card_being_dragged.global_position = slot_encontrado.global_position
			# marcarem o slot manualmente
			slot_encontrado.card_in_slot = card_being_dragged
			card_being_dragged.locked_in_slot = true
			card_being_dragged.set_meta("slot_ref", slot_encontrado)
	else:
		# Falhou: volta para a mão (snap back)
		if player_hand:
			player_hand.add_card_to_hand(card_being_dragged)
		card_being_dragged.locked_in_slot = false
		if card_being_dragged.has_meta("slot_ref"):
			card_being_dragged.remove_meta("slot_ref")

	card_being_dragged = null
	card_target_slot = null
	_hide_card_preview()

# ---------------------------------------------------------
# HIGHLIGHT DA CARTA
# ---------------------------------------------------------
func highlight_card(card, hovered):
	if hovered:
		# If the card is locked in a slot, don't change scale (prevents cursor leaving area)
		if card.locked_in_slot:
			card.z_index = 3
		else:
			card.scale = Vector2(1, 1)
			card.z_index = 2
	else:
		if card.locked_in_slot:
			card.z_index = 1
		else:
			card.scale = Vector2(0.8, 0.8)
			card.z_index = 1


# ---------------------------------------------------------
# RAYCAST PARA ENCONTRAR A CARTA SOB O MOUSE
# ---------------------------------------------------------
func raycast_check_for_card():
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISSION_MASK_CARD
	
	var result = space_state.intersect_point(parameters)

	if result.size() > 0:
		var parent = result[0].collider.get_parent()

		# Evita que slots ou qualquer outra coisa seja detectada como carta
		if parent.is_in_group("card"):
			return parent

	# fallback: se não encontramos uma carta diretamente, verifique se há um slot sob o mouse
	var slot = raycast_check_for_card_slot()
	if slot and slot.card_in_slot:
		return slot.card_in_slot

	return null
	
# ---------------------------------------------------------
# RAYCAST PARA O SLOT DE CARTAS
# ---------------------------------------------------------
func raycast_check_for_card_slot(exception = null):
	var space_state = get_world_2d().direct_space_state
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	parameters.collision_mask = COLLISSION_MASK_CARD_SLOT

	# Se houver uma exceção (a carta sendo arrastada), ignore sua Area2D usando RID
	if exception:
		var area = exception.get_node_or_null("Area2D")
		if area:
			parameters.exclude = [area.get_rid()]

	var result = space_state.intersect_point(parameters)

	if result.size() > 0:
		# parent = carta (Node2D), Area2D = collider
		return result[0].collider.get_parent()
	return null

# ---------------------------------------------------------
# HUD - PREVIEW DA CARTA
# ---------------------------------------------------------
func _show_card_preview(card):
	var hud = get_tree().get_root().get_node("Main/CanvasLayer")
	hud.show_card_preview(card)


func _hide_card_preview():
	var hud = get_tree().get_root().get_node("Main/CanvasLayer")
	hud.hide_card_preview()

func _on_viewport_size_changed():
	screen_size = get_viewport().get_visible_rect().size

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var card = raycast_check_for_card()
			if card:
				if card.locked_in_slot:
					return
				card_being_dragged = card
		else:
			if card_being_dragged:
				var slot_found = raycast_check_for_card_slot(card_being_dragged)
				if slot_found and slot_found.card_in_slot == null:
					if played_monster_this_turn:
						print("Você já jogou um monstro neste turno!")
						return_card_to_hand(card_being_dragged)
					else:
						player_hand.remove_card_from_hand(card_being_dragged)
						slot_found.accept_card(card_being_dragged)
						card_being_dragged.global_position = slot_found.global_position
						played_monster_this_turn = true
				else:
					return_card_to_hand(card_being_dragged)
				card_being_dragged = null

func return_card_to_hand(card):
	player_hand.add_card_to_hand(card)
	card.locked_in_slot = false
	if card.has_meta("slot_ref"):
		card.remove_meta("slot_ref")
