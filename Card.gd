extends Node2D

var card_in_slot: Node2D = null
var locked_in_slot: bool = false
var hand_position: Vector2 = Vector2()

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
