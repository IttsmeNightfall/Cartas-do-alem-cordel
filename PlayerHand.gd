extends Node2D

const CARD_SCENE_PATH = "res://Card.tscn" # Verifique se o caminho bate com o seu projeto
const HAND_COUNT = 5 # Quantas cartas começam na mão
const CARD_WIDTH = 200 # Distância entre as cartas (ajuste conforme o tamanho da sua arte)
const DEFAULT_CARD_SPEED = 0.1

@export var HAND_Y_OFFSET: int = 175 # distância em pixels do fundo da tela

var player_hand = [] # Array para guardar as cartas que estão na mão
var center_screen_x = 0

@onready var card_manager = $"../CardManager" # Ajuste o caminho para o seu CardManager

func _ready():
	# Deck will instantiate cards now
	# Ensure we know the center X of the visible viewport
	center_screen_x = get_viewport().get_visible_rect().size.x / 2
	pass

func add_card_to_hand(card, speed = DEFAULT_CARD_SPEED):
	if card not in player_hand:
		# Nova carta entrando na mão
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		# Carta que já estava na mão e foi solta no "vazio" (Snap Back)
		animate_card_to_position(card, card.hand_position, speed)

func update_hand_positions(speed = DEFAULT_CARD_SPEED):
	for i in range(player_hand.size()):
		var card = player_hand[i]
		# Calcula a nova posição baseada no índice
		var new_position = calculate_card_position(i)
		
		# Guarda essa posição na carta (para ela saber para onde voltar)
		card.hand_position = new_position
		
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	# Ensure center is valid and up-to-date
	center_screen_x = get_viewport().get_visible_rect().size.x / 2

	# Position the hand a fixed offset from the bottom of the viewport
	var viewport_h = get_viewport().get_visible_rect().size.y
	var hand_y = clamp(viewport_h - HAND_Y_OFFSET, 50, viewport_h - 50)

	var total_width = (player_hand.size() - 1) * CARD_WIDTH
	var x_offset = center_screen_x + (index * CARD_WIDTH) - (total_width / 2.0)
	return Vector2(x_offset, hand_y)

func animate_card_to_position(card, new_position, speed = DEFAULT_CARD_SPEED):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
