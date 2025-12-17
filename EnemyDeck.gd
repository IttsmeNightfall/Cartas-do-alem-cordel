extends Node2D

const CARD_SCENE_PATH = "res://OpponentCard.tscn" # Ou "res://EnemyCard.tscn" se tiver criado
const CARD_DRAW_SPEED = 0.2
const CARD_DATABASE_PATH = "res://CardDatabase.gd"

# Lista de cartas do Inimigo (Pode ser igual ou diferente da do jogador)
var enemy_deck_list = [
	"Cachaceiro", "Cachaceiro", 
	"Briguento", "Briguento",
	"Zeca-Peito-de-Ferro", 
	"Velho do Saco",
	"Matilha", "Matilha",
	"Curupira",
	"Boto-Cor-de-Rosa"
]
var card_database

# --- MUDANÇA 1: Referência à Mão do Oponente ---
@onready var opponent_hand = $"../OpponentHand" 
@onready var card_manager = $"../CardManager" 
@onready var rich_text_label = $RichTextLabel

func _ready():
	enemy_deck_list.shuffle()
	
	if rich_text_label:
		rich_text_label.text = str(enemy_deck_list.size())
		
	card_database = preload(CARD_DATABASE_PATH)

	# Compra 5 cartas iniciais para o INIMIGO
	for i in range(5):
		draw_card(true)

func draw_card(is_start = false):
	# O inimigo não clica, então não precisamos checar 'drawn_card_this_turn' aqui
	# Quem controla quando ele compra é o BattleManager

	if enemy_deck_list.size() > 0:
		var card_name = enemy_deck_list[0]
		enemy_deck_list.remove_at(0)

		var new_card = preload(CARD_SCENE_PATH).instantiate()
		
		# Define os dados da carta
		if card_database and card_name in card_database.CARDS:
			new_card.set_card_data(card_database.CARDS[card_name])
			
		# Adiciona visualmente na cena
		if card_manager:
			card_manager.add_child(new_card)
		
		new_card.global_position = global_position
		
		# --- MUDANÇA 2: Manda para a mão do OPONENTE ---
		if opponent_hand:
			opponent_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		else:
			print("ERRO: Nó OpponentHand não encontrado!")

		if rich_text_label:
			rich_text_label.text = str(enemy_deck_list.size())

		if enemy_deck_list.size() == 0:
			visible = false
