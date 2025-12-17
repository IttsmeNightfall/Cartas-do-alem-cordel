extends Node2D

const CARD_SCENE_PATH = "res://Card.tscn"
const HAND_COUNT = 5
const CARD_WIDTH = 80 
const DEFAULT_CARD_SPEED = 0.1

# Ajuste este valor. Como é o oponente (topo da tela):
# 50 ou 80 = Cartas bem no topo.
# 150 = Cartas descem um pouco mais.
@export var HAND_Y_OFFSET: int = 0

# Mudei o nome da variável para não confundir com a do jogador
var opponent_hand = [] 

# Não precisamos do CardManager aqui necessariamente, mas se seu código usar, pode manter
# @onready var card_manager = $"../CardManager" 

func _ready():
	var screen_size = get_viewport().get_visible_rect().size
	print("RESOLUÇÃO (OPONENTE): ", screen_size)

func add_card_to_hand(card, speed = DEFAULT_CARD_SPEED):
	if card not in opponent_hand:
		# Adiciona a carta na lista do oponente
		opponent_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, speed)

func update_hand_positions(speed = DEFAULT_CARD_SPEED):
	for i in range(opponent_hand.size()):
		var card = opponent_hand[i]
		var new_position = calculate_card_position(i)
		
		card.hand_position = new_position
		
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	var viewport_size = get_viewport().get_visible_rect().size
	
	# --- MUDANÇA PRINCIPAL AQUI (EIXO Y) ---
	# Jogador: viewport_size.y - HAND_Y_OFFSET (Fundo da tela)
	# Oponente: HAND_Y_OFFSET (Topo da tela)
	var hand_y = HAND_Y_OFFSET
	
	# --- EIXO X (Mantém centralizado igual) ---
	var total_hand_width = (opponent_hand.size() - 1) * CARD_WIDTH
	var x_offset = (viewport_size.x / 2.0) - (total_hand_width / 2.0) + (index * CARD_WIDTH)
	
	return Vector2(x_offset, hand_y)

func animate_card_to_position(card, new_position, speed = DEFAULT_CARD_SPEED):
	var tween = get_tree().create_tween()
	tween.tween_property(card, "global_position", new_position, speed)

func remove_card_from_hand(card):
	if card in opponent_hand:
		opponent_hand.erase(card)
		update_hand_positions()
