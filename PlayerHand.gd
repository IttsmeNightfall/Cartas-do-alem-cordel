extends Node2D

const CARD_SCENE_PATH = "res://OpponentCard.tscn"
const HAND_COUNT = 5
const CARD_WIDTH = 80 # Reduzi um pouco para ficarem mais agrupadas, ajuste se precisar
const DEFAULT_CARD_SPEED = 0.1

# Ajuste este valor. Como sua tela tem 962 de altura:
# 100 = Cartas bem na base.
# 150 = Cartas um pouco mais para cima.
@export var HAND_Y_OFFSET: int = 80 

var player_hand = [] 
@onready var card_manager = $"../CardManager"

func _ready():
	# Debug para ver se o Godot está lendo a resolução certa
	var screen_size = get_viewport().get_visible_rect().size
	print("RESOLUÇÃO DETECTADA PELO SCRIPT: ", screen_size)

func add_card_to_hand(card, speed = DEFAULT_CARD_SPEED):
	if card not in player_hand:
		player_hand.insert(0, card)
		update_hand_positions(speed)
	else:
		animate_card_to_position(card, card.hand_position, speed)

func update_hand_positions(speed = DEFAULT_CARD_SPEED):
	for i in range(player_hand.size()):
		var card = player_hand[i]
		var new_position = calculate_card_position(i)
		
		# Salva a posição alvo
		card.hand_position = new_position
		
		# IMPORTANTE: Usa a animação global
		animate_card_to_position(card, new_position, speed)

func calculate_card_position(index):
	# Pega o tamanho ATUAL da janela (se você maximizar, ele atualiza)
	var viewport_size = get_viewport().get_visible_rect().size
	
	# 1. Define a Altura (Y)
	# Pega a altura total e sobe o valor do OFFSET
	var hand_y = viewport_size.y - HAND_Y_OFFSET
	
	# 2. Define a Largura (X) para Centralizar
	# Largura total que as cartas ocupam juntas
	var total_hand_width = (player_hand.size() - 1) * CARD_WIDTH
	
	# Fórmula: (Meio da Tela) - (Metade do Grupo de Cartas) + (Posição desta carta)
	var x_offset = (viewport_size.x / 2.0) - (total_hand_width / 2.0) + (index * CARD_WIDTH)
	
	return Vector2(x_offset, hand_y)

func animate_card_to_position(card, new_position, speed = DEFAULT_CARD_SPEED):
	var tween = get_tree().create_tween()
	# MUDANÇA CRÍTICA: 'global_position' garante que o cálculo da tela funcione
	# independente de onde o nó 'PlayerHand' ou 'CardManager' estejam.
	tween.tween_property(card, "global_position", new_position, speed)

func remove_card_from_hand(card):
	if card in player_hand:
		player_hand.erase(card)
		update_hand_positions()
