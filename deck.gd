extends Node2D

const CARD_SCENE_PATH = "res://Card.tscn"
const CARD_DATABASE_PATH = "res://CardDatabase.gd" # Ajuste o caminho!
const CARD_DRAW_SPEED = 0.2

var player_deck = ["Cachaceiro", "Briguento", "Matilha", "Zeca-Peito-de-Ferro"] # Nomes variados
var card_database # Variável para guardar o script carregado

@onready var player_hand = $"../PlayerHand"
@onready var rich_text_label = $RichTextLabel

func _ready():
	player_deck.shuffle() # Embaralha o deck
	rich_text_label.text = str(player_deck.size())
	# Carrega o script do Database
	card_database = preload(CARD_DATABASE_PATH)

func draw_card():
	if player_deck.size() > 0:
		var card_name = player_deck[0]
		player_deck.remove_at(0)
		
		var new_card = preload(CARD_SCENE_PATH).instantiate()
		# Ajuste para carregar imagens diferentes
		# Certifique-se de ter as imagens: "KnightCard.png", "ArcherCard.png", etc. na pasta assets
		var image_path = "res://assets/" + card_name + "Card.png"
		new_card.get_node("CardImg").texture = load(image_path)
		
		# --- Configurar Ataque e Vida ---
		var card_data = card_database.CARDS[card_name]
		var attack_val = card_data[0] # Usando índice direto ou enum se preferir
		var health_val = card_data[1]
		
		# Assume que você criou labels na carta (veja passo 3 abaixo)
		new_card.get_node("AttackLabel").text = str(attack_val)
		new_card.get_node("HealthLabel").text = str(health_val)
		
		# ... (resto da lógica de instanciar e mover para a mão igual antes) ...
		$"../CardManager".add_child(new_card)
		new_card.name = "Card"
		new_card.global_position = global_position
		player_hand.add_card_to_hand(new_card, CARD_DRAW_SPEED)
		
		# Tocar animação de flip (veremos na Parte 2)
		# new_card.get_node("AnimationPlayer").play("card_flip")
		
		rich_text_label.text = str(player_deck.size())
		if player_deck.size() == 0:
			visible = false
			$Area2D/CollisionShape2D.disabled = true
