extends Node2D

# referência para a carta que está no slot (null quando vazio)
var card_in_slot: Node2D = null

func accept_card(card):
	if card_in_slot != null:
		return false

	card_in_slot = card
	card.locked_in_slot = true
	# guarda referência ao slot na própria carta (para poder liberar quando for pegar)
	card.set_meta("slot_ref", self)
	card.card_slot_card_is_in = self # Carta agora sabe onde está

	# centraliza automaticamente no slot usando global_position
	card.global_position = global_position

	# garante escala/visuais corretos enquanto estiver no slot
	card.scale = Vector2(0.8, 0.8)
	card.z_index = 1

	return true


func remove_card():
	if card_in_slot:
		card_in_slot.locked_in_slot = false
		# remove referência ao slot armazenada em meta
		if card_in_slot.has_meta("slot_ref"):
			card_in_slot.remove_meta("slot_ref")
		card_in_slot.card_slot_card_is_in = null # Limpa a referência ao slot na carta
		# restaura escala padrão ao remover do slot
		card_in_slot.scale = Vector2(0.8, 0.8)
		card_in_slot = null
