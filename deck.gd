extends Node2D

const CARD_SCENE_PATH = "res://Card.tscn"
const CARD_DRAW_SPEED = 0.2
const CARD_DATABASE_PATH = "res://CardDatabase.gd"

var player_deck = [
	# Iniciais / Comuns (Algumas repetidas para consistência)
	"Cachaceiro", "Cachaceiro", 
	"Briguento", "Briguento",
	"Zeca-Peito-de-Ferro", 
	"Velho do Saco",
	
	# Bichos
	"Matilha", "Matilha",
	"Curupira",
	"Boto-Cor-de-Rosa",
	"Chupa Cabra",
	"Encourado",
	
	# Sertanejos
	"O Sanfoneiro",
	"Terezinha",
	"Cabra da Peste",
	"Coronel Bezerra",
	
	# Malassombrados
	"Mula sem Cabeça",
	"Corpo-Seco",
	"Cumade-Fulozinha",
	
	# Cangaceiros / Chefes (Cartas Fortes)
	"Balão",
	"O Diabo Loiro",
	"Besta Fera"
]
var card_database

# Variável para controlar se já comprou uma carta neste turno
var drawn_card_this_turn: bool = false

@onready var player_hand = $"../PlayerHand"
@onready var rich_text_label = $RichTextLabel

func _ready():
	player_deck.shuffle()
	rich_text_label.text = str(player_deck.size())
	card_database = preload(CARD_DATABASE_PATH)

	# Compra as cartas iniciais sem gastar a jogada do turno
	for i in range(5):
		draw_card(true)
	drawn_card_this_turn = true

func draw_card(is_start = false):
	if not is_start and drawn_card_this_turn:
		print("Você já comprou uma carta neste turno!")
		return

	if player_deck.size() > 0:
		var card_name = player_deck[0]
		player_deck.remove_at(0)

		var new_card = preload(CARD_SCENE_PATH).instantiate()
		new_card.set_card_data(card_database.CARDS[card_name])
		$"../CardManager".add_child(new_card)
		new_card.global_position = global_position
		player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)

		rich_text_label.text = str(player_deck.size())
		if not is_start:
			drawn_card_this_turn = true

# ... (resto do código anterior)

		if player_deck.size() == 0:
			visible = false
			
			# PROCURA o nó automaticamente (Recursivo = true)
			var collision = find_child("CollisionShape2D", true, false)
			
			if collision:
				collision.disabled = true
			else:
				print("ERRO: CollisionShape2D não encontrado! Verifique os nomes na aba Cena.")
