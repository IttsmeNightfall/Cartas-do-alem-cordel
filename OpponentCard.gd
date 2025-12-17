extends Node2D

var card_in_slot: Node2D = null
var locked_in_slot: bool = false
var hand_position: Vector2 = Vector2()

# Variáveis para armazenar os atributos da carta
var attack: int = 0
var health: int = 0
var card_type: String = "Comum" # Tipo padrão

# Configura os dados da carta com base no CardDatabase
func set_card_data(data):
	attack = data[0]
	health = data[1]
	card_type = data[2]

func accept_card(card):
	if card_in_slot != null:
		return false

	card_in_slot = card
	card.locked_in_slot = true

	# Centraliza automaticamente
	card.global_position = global_position

	return true

func remove_card():
	if card_in_slot:
		card_in_slot.locked_in_slot = false
		card_in_slot = null
